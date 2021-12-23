import Foundation

@inlinable
public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

@inlinable
public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(lhs) == deepDescription(rhs)
}

@usableFromInline
func deepDescription(_ instance: Any) -> String {
    instancesToDescribe(parent: instance).map {
        mirror($0).hasChildren
        ? deepDescription($0)
        : shallowDescription($0)
        + shallowObjCDescription($0)
    }.joined()
}

@usableFromInline
func shallowObjCDescription(_ instance: Any) -> String {
    guard let instance = instance as? NSObject else { return "" }
    
    return instance
        .propertyValues
        .map(shallowDescription)
        .joined()
}

@usableFromInline
func instancesToDescribe(parent: Any) -> [Any] {
    mirror(parent).childInstances ??? [parent]
}

@usableFromInline
func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

@usableFromInline
func shallowDescription(_ instance: Any) -> String {
    let description = String(describing: instance)
    
    return instance is Stringy
    ? description
    : description.removingClassIDs
}

extension Mirror {
    @usableFromInline
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    @usableFromInline
    var superclassHasChildren: Bool {
        superclassMirror?.hasChildren ?? false
    }
    
    @usableFromInline
    var childInstances: [Any] {
        children.map(\.value) + superclassChildInstances
    }
    
    @usableFromInline
    var superclassChildInstances: [Any] {
        superclassMirror?.childInstances ?? []
    }
}

extension String {
    @usableFromInline
    var removingClassIDs: String {
        removingMatches("[ =(]0x[0-9a-f]{\(hexLength)}")
    }
    
    @usableFromInline
    var hexLength: Int {
        NSObject().description.count - "<NSObject: 0x>".count
    }
    
    @usableFromInline
    func removingMatches(_ regex: String) -> String {
        replacingOccurrences(of: regex,
                             with: "",
                             options: .regularExpression)
    }
}

protocol Stringy {}

extension String: Stringy {}
extension Substring: Stringy {}
extension NSString: Stringy {}

infix operator ???

@usableFromInline
func ???(_ lhs: [Any]?, _ rhs: [Any]) -> [Any] {
    (lhs?.isEmpty ?? true) ? rhs : lhs!
}
