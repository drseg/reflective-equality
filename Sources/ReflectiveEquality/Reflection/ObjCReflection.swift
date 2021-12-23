import Foundation

extension NSObject {
    typealias UMP<T> = UnsafeMutablePointer<T>
    
    public var propertiesAndIvars: [String: Any] {
        ivars.merging(properties)
    }

    public var ivars: [String: Any] {
        valuesDictionary(forKeys: ivarPointersDictionary.keys)
    }

    public var properties: [String: Any] {
        valuesDictionary(forKeys: propertyPointersDictionary.keys)
    }
    
    public var propertyAndIvarValues: [Any] {
        propertyValues + ivarValues
    }
    
    public var propertyValues: [Any] {
        valuesArray(forKeys: propertyKeys)
    }
    
    public var ivarValues: [Any] {
        valuesArray(forKeys: ivarKeys)
    }
    
    func valuesDictionary<C: Collection>(
        forKeys keys: C
    ) -> [String: Any] where C.Element == String {
        guard isMirrorSafe else { return ["": description] }
        
        return keys.reduce(into: [String: Any]()) { result, key in
            result[key] = safeValue(forKey: key)
        }
    }
    
    func valuesArray<C: Collection>(
        forKeys keys: C
    ) -> [Any] where C.Element == String {
        guard isMirrorSafe else { return [description] }
        
        return keys.reduce([Any]()) { partialResult, key in
            partialResult + [safeValue(forKey: key)].compactMap { $0 }
        }
    }
    
    func safeValue(forKey key: String) -> Any? {
        suppressExceptions { self.value(forKey: key) }
    }
    
    var isMirrorSafe: Bool {
        !(self is SwiftMirrorUnsafe)
    }
    
    var ivarKeys: [String] {
        allKeys(getList: class_copyIvarList,
                getName: ivar_getName)
    }
    
    var propertyKeys: [String] {
        allKeys(getList: class_copyPropertyList,
                getName: property_getName)
    }
    
    var ivarPointersDictionary: [String: Any] {
        deepPointerDictionary(getList: class_copyIvarList,
                              getName: ivar_getName,
                              getItem: class_getInstanceVariable)
    }
    
    var propertyPointersDictionary: [String: Any] {
        deepPointerDictionary(getList: class_copyPropertyList,
                              getName: property_getName,
                              getItem: class_getProperty)
    }
    
    func deepPointerDictionary<T>(
        type: AnyClass? = nil,
        getList: (AnyClass?, UMP<UInt32>?) -> UMP<T>?,
        getName: (T) -> UnsafePointer<CChar>?,
        getItem: (AnyClass?, UnsafePointer<CChar>) -> OpaquePointer?
    ) -> [String: Any] {
        allKeys(getList: getList, getName: getName)
            .reduce(into: [String: Any]()) { dictionary, key in
                dictionary[key] = getItem(type ?? Self.self, key)
            }
    }
    
    func allKeys<T>(
        type: AnyClass? = nil,
        getList: (AnyClass?, UMP<UInt32>?) -> UMP<T>?,
        getName: (T) -> UnsafePointer<CChar>?
    ) -> [String] {
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
    
    func keys<T>(
        type: AnyClass,
        getList: (AnyClass?, UMP<UInt32>?) -> UMP<T>?,
        getName: (T) -> UnsafePointer<CChar>?
    ) -> [String] {
        guard type != NSObject.self else { return [] }
        
        var count: UInt32 = 0
        let cList = getList(type, &count)
        
        return (0..<count).reduce(into: [String]()) { result, i in
            if let item = cList?[Int(i)], let cKey = getName(item) {
                let key = String(cString: cKey)
                if key.isIncluded {
                    result.append(key)
                }
            }
        }
    }
}

extension String {
    var isIncluded: Bool {
        !["description", "debugDescription"].contains(self)
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
