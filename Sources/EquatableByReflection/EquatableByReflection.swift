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

fileprivate func hasChildren(_ candidate: Any) -> Bool {
    mirror(of: candidate).hasProperties
}

fileprivate func childrenAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    children(of: lhs) == children(of: rhs)
}

fileprivate func descriptionsAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    description(of: lhs) == description(of: rhs)
}

fileprivate func children(of any: Any) -> String {
    let properties = mirror(of: any)
        .children
        .map(\.value)
        .map(subChildren)

    return description(of: properties)
}

fileprivate func mirror(of any: Any) -> Mirror {
    Mirror(reflecting: any)
}

fileprivate func description(of any: Any) -> String {
    String(describing: any)
}

fileprivate func subChildren(of any: Any) -> Any {
    var isClass: Bool {
        mirror(of: any).displayStyle == .class
    }
    
    return hasChildren(any)
    ? children(of: any)
    : isClass
       ? comparableClassDescription(of: any)
       : description(of: any)
}

fileprivate func comparableClassDescription(of any: Any) -> Any {
    let description = description(of: any)
    
    return description.isClassID
    ? description.className
    : description
}

fileprivate extension Mirror {
    var hasProperties: Bool {
        !children.isEmpty
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

