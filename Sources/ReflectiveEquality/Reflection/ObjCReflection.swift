import Foundation
import ExceptionCatcher

public func suppressExceptions<T>(in block: @escaping () -> (T?)) -> T? {
    var result: T?
    try? Exceptions.intercept {
        result = block()
    }
    return result
}

protocol SwiftMirrorUnsafe {}
extension NSString: SwiftMirrorUnsafe {}
extension NSNumber: SwiftMirrorUnsafe {}

public extension NSObject {
    
    var propertiesAndIvars: [String: Any] {
        ivars.merging(properties)
    }

    var ivars: [String: Any] {
        valuesDictionary(forKeys: ivarPointersDictionary.keys)
    }

    var properties: [String: Any] {
        valuesDictionary(forKeys: propertyPointersDictionary.keys)
    }
    
    var propertyAndIvarValues: [Any] {
        propertyValues + ivarValues
    }
    
    var propertyValues: [Any] {
        valuesArray(forKeys: propertyKeys)
    }
    
    var ivarValues: [Any] {
        valuesArray(forKeys: ivarKeys)
    }
    
    internal func valuesDictionary<C: Collection>(forKeys keys: C) -> [String: Any] where C.Element == String {
        guard isMirrorSafe else { return ["": description] }
        
        return keys.reduce(into: [String: Any]()) { partialResult, key in
            partialResult[key] = safeValue(forKey: key)
        }
    }
    
    internal func valuesArray<C: Collection>(forKeys keys: C) -> [Any] where C.Element == String {
        guard isMirrorSafe else { return [description] }
        
        return keys.reduce([Any]()) { partialResult, key in
            partialResult + [safeValue(forKey: key)].compactMap { $0 }
        }
    }
    
    internal func safeValue(forKey key: String) -> Any? {
        suppressExceptions { self.value(forKey: key) }
    }
    
    internal var isMirrorSafe: Bool {
        !(self is SwiftMirrorUnsafe)
    }
    
    internal var ivarKeys: [String] {
        allKeys(getList: class_copyIvarList,
                getName: ivar_getName)
    }
    
    internal var propertyKeys: [String] {
        allKeys(getList: class_copyPropertyList,
                getName: property_getName)
    }
    
    internal var ivarPointersDictionary: [String: Any] {
        deepPointerDictionary(getList: class_copyIvarList,
                              getName: ivar_getName,
                              getItem: class_getInstanceVariable)
    }
    
    internal var propertyPointersDictionary: [String: Any] {
        deepPointerDictionary(getList: class_copyPropertyList,
                              getName: property_getName,
                              getItem: class_getProperty)
    }
    
    internal func deepPointerDictionary<T>(type: AnyClass? = nil, getList: (AnyClass?, UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<T>?, getName: (T) -> UnsafePointer<CChar>?, getItem: (AnyClass?, UnsafePointer<CChar>) -> OpaquePointer?) -> [String: Any] {
        allKeys(getList: getList, getName: getName).reduce(into: [String: Any]()) { dictionary, key in
            dictionary[key] = getItem(type ?? Self.self, key)
        }
    }
    
    internal func allKeys<T>(type: AnyClass? = nil, getList: (AnyClass?, UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<T>?, getName: (T) -> UnsafePointer<CChar>?) -> [String] {
        let type: AnyClass = type ?? Self.self
        
        let keys = keys(type: type,
                        getList: getList,
                        getName: getName)
        
        return type.superclass() != nil
        ? keys + allKeys(type: type.superclass(),
                         getList: getList,
                         getName: getName)
        : keys
    }
    
    internal func keys<T>(type: AnyClass, getList: (AnyClass?, UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<T>?, getName: (T) -> UnsafePointer<CChar>?) -> [String] {
        guard type != NSObject.self else { return [] }
        
        var count: CUnsignedInt = 0
        let cList = getList(type, &count)
        
        return (0..<count).reduce(into: [String]()) { result, i in
            if let item = cList?[Int(i)],
               let cKey = getName(item)
            {
                let key = String(cString: cKey)
                if key.isIncluded {
                    result.append(key)
                }
            }
        }
    }
}

let keysToExclude = ["description", "debugDescription"]

extension String {
    
    var isIncluded: Bool {
        !keysToExclude.contains(self)
    }
}

extension Dictionary {
    
    enum MergePrecedence {
        case this, other
    }
    
    func merging(_ other: [Key : Value], mergePrecedence: MergePrecedence = .this) -> [Key : Value] {
        merging(other) { this, other in
            mergePrecedence == .this ? this : other
        }
    }
}
