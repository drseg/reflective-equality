import Foundation

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    guard sameType(lhs, rhs) else { return false }
    
    return hasChildren(lhs)
    ? childDescriptionsAreEqual(lhs, rhs)
    : descriptionsAreEqual(lhs, rhs)
}

fileprivate func sameType(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs)
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func childDescriptionsAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    children(of: lhs) == children(of: rhs)
}

fileprivate func descriptionsAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    description(of: lhs) == description(of: rhs)
}

fileprivate func children(of instance: Any) -> String {
    description(
        of: mirror(of: instance)
            .childValues
            .map(subChildren)
    )
}

fileprivate func mirror(of instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func description(of instance: Any) -> String {
    String(describing: instance)
}

fileprivate func subChildren(of instance: Any) -> Any {
    hasChildren(instance)
    ? children(of: instance)
    : formattedDescription(of: instance)
}

fileprivate func formattedDescription(of instance: Any) -> Any {
    let description = description(of: instance)
    
    return description.isClassID
    ? description.className
    : description
}

fileprivate extension Mirror {
    
    var hasChildren: Bool {
        !children.isEmpty
    }
    
    var childValues: [Any] {
        children.map(\.value)
    }
}

fileprivate extension String {
    
    var className: Any {
        split(separator: ":")
            .first!
            .dropFirst()
    }
    
    var isClassID: Bool {
        first == "<"
    }
}

