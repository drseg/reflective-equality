public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(of: lhs) == deepDescription(of: rhs)
}

fileprivate func deepDescription(of instance: Any) -> String {
    instancesToDescribe(parent: instance).map {
        hasChildren($0)
        ? deepDescription(of: $0)
        : shallowDescription(of: $0)
    }.joined()
}

fileprivate func instancesToDescribe(parent: Any) -> [Any] {
    let childInstances = mirror(of: parent).childInstances
    return childInstances.isEmpty ? [parent] : childInstances
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func mirror(of instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func shallowDescription(of instance: Any) -> String {
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
