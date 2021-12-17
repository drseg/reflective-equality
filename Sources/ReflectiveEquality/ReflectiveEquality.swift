import Foundation

public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(lhs) == deepDescription(rhs)
}

fileprivate func deepDescription(_ instance: Any) -> String {
    instancesToDescribe(parent: instance).map {
        mirror($0).hasChildren
        ? deepDescription($0)
        : shallowDescription($0)
    }.joined()
}

fileprivate func instancesToDescribe(parent: Any) -> [Any] {
    if let attributedString = parent as? NSAttributedString {
        return [attributedString.string, attributedString]
    }
    
    return mirror(parent).childInstances ??? [parent]
}

fileprivate func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func shallowDescription(_ instance: Any) -> String {
    let description = String(describing: instance)
    
    return instance is Stringy
    ? description
    : description.removingClassIDs
}

fileprivate extension Mirror {
    
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    var childInstances: [Any] {
        children.isEmpty
        ? superclassChildInstances
        : children.map(\.value) + superclassChildInstances
    }
    
    var superclassHasChildren: Bool {
        superclass?.hasChildren ?? false
    }
    
    var superclassChildInstances: [Any] {
        superclass?.childInstances ?? []
    }
    
    var superclass: Mirror? {
        superclassMirror
    }
}

fileprivate extension String {
    
    var removingClassIDs: String {
        let hexLength = NSObject().description.count - "<NSObject: 0x>".count
        let regex = "[ (]0x[0-9a-f]{\(hexLength)}"
        
        return replacingOccurrences(of: regex,
                                    with: "",
                                    options: .regularExpression)
    }
}

fileprivate protocol Stringy {}

extension String: Stringy {}
extension Substring: Stringy {}
extension NSString: Stringy {}

infix operator ???

func ???(_ lhs: [Any]?, _ rhs: [Any]) -> [Any] {
    (lhs?.isEmpty ?? true) ? rhs : lhs!
}
