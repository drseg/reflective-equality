public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    recursiveDescription(of: lhs) == recursiveDescription(of: rhs)
}

fileprivate func recursiveDescription(of instance: Any) -> String {
    let childInstances = mirror(of: instance).childInstances
    let instancesToDescribe = childInstances.isEmpty ? [instance] : childInstances
    let descriptions = instancesToDescribe.map {
        hasChildren($0)
        ? recursiveDescription(of: $0)
        : description(of: $0)
    }
    
    return descriptions.joined()
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func mirror(of instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func description(of instance: Any) -> String {
    let description = String(describing: instance)
    
    return description.isClassID
    ? description.className
    : description
}

fileprivate extension Mirror {
    
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    var superclassHasChildren: Bool {
        superclass?.hasChildren ?? false
    }
    
    var childInstances: [Any] {
        children.isEmpty
        ? superclassChildInstances
        : children.map(\.value) + superclassChildInstances
    }
    
    var superclassChildInstances: [Any] {
        superclass?.childInstances ?? []
    }
    
    var superclass: Mirror? {
        superclassMirror
    }
}

fileprivate extension String {
    
    var className: String {
        String(split(separator: ":")
                .first!
                .dropFirst())
    }
    
    var isClassID: Bool {
        first == "<"
    }
}
