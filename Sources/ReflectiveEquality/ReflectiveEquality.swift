import Foundation

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    if typesDiffer(lhs, rhs) {
        return false
    }
    
    return hasChildren(lhs)
    ? childrenAreEqual(lhs, rhs)
    : descriptionsAreEqual(lhs, rhs)
}

fileprivate func typesDiffer(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) != type(of: rhs)
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func childrenAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
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
    return hasChildren(instance)
        ? children(of: instance)
        : mirror(of: instance).reflectsClass
            ? comparableClassDescription(of: instance)
            : description(of: instance)
}

fileprivate func comparableClassDescription(of instance: Any) -> Any {
    let description = description(of: instance)
    
    return description.isClassID
    ? description.className
    : description
}

fileprivate extension Mirror {
    var reflectsClass: Bool {
        displayStyle == .class
    }
    
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

