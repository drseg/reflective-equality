public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    guard sameType(lhs, rhs) else { return false }
    
    return hasChildren(lhs)
    ? equalByRecursiveDescription(lhs, rhs)
    : equalByDescription(lhs, rhs)
}

fileprivate func sameType(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs)
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func equalByRecursiveDescription(_ lhs: Any, _ rhs: Any) -> Bool {
    recursiveDescription(of: lhs) == recursiveDescription(of: rhs)
}

fileprivate func equalByDescription(_ lhs: Any, _ rhs: Any) -> Bool {
    formattedDescription(of: lhs) == formattedDescription(of: rhs)
}

fileprivate func recursiveDescription(of instance: Any) -> String {
    mirror(of: instance)
        .childValues
        .map(formattedRecursiveDescription)
        .joined()
}

fileprivate func mirror(of instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func formattedRecursiveDescription(of instance: Any) -> String {
    hasChildren(instance)
    ? recursiveDescription(of: instance)
    : formattedDescription(of: instance)
}

fileprivate func formattedDescription(of instance: Any) -> String {
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
    
    var childValues: [Any] {
        children.isEmpty
        ? superclassChildValues
        : children.map(\.value) + superclassChildValues
    }
    
    var superclassChildValues: [Any] {
        superclass?.childValues ?? []
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
