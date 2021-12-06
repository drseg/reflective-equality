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
    mirror(parent).childInstances ??? [parent]
}

fileprivate func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func shallowDescription(_ instance: Any) -> String {
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
    
    var className: String {
        String(split(separator: ":")
                .first!
                .dropFirst())
    }
    
    var isClassID: Bool {
        first == "<"
    }
}

infix operator ???

func ???(_ lhs: [Any]?, _ rhs: [Any]) -> [Any] {
    (lhs?.isEmpty ?? true) ? rhs : lhs!
}
