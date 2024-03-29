import Foundation

public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(lhs) == deepDescription(rhs)
}

public func deepDescription(_ instance: Any) -> String {
    instancesToDescribe(parent: instance).map {
        mirror($0).hasChildren
        ? deepDescription($0)
        : shallowDescription($0)
        + shallowObjCDescription($0)
    }.joined() + shallowDescription(instance)
}

func shallowObjCDescription(_ instance: Any) -> String {
    guard let instance = instance as? NSObject else {
        return ""
    }
    
    return instance
        .propertyValues
        .map(shallowDescription)
        .joined()
}

func instancesToDescribe(parent: Any) -> [Any] {
    mirror(parent).childInstances ??? [parent]
}

func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

func shallowDescription(_ instance: Any) -> String {
    let description = String(describing: instance)
    
    return instance is HexNumbersAllowed
    ? description
    : description.removingClassIDs
}

extension Mirror {
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    var superclassHasChildren: Bool {
        superclassMirror?.hasChildren ?? false
    }
    
    var childInstances: [Any] {
        children.map(\.value) + superclassChildInstances
    }
    
    var superclassChildInstances: [Any] {
        superclassMirror?.childInstances ?? []
    }
}

extension String {
    var removingClassIDs: String {
        removingMatches("[ =(]0x[0-9a-f]+")
    }
    
    func removingMatches(_ regex: String) -> String {
        replacingOccurrences(of: regex,
                             with: "",
                             options: .regularExpression)
    }
}

infix operator ???

func ???(_ lhs: [Any], _ rhs: [Any]) -> [Any] {
    lhs.isEmpty ? rhs : lhs
}
