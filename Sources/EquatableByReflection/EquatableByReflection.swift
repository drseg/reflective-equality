import Foundation

func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    if typesDiffer(lhs, rhs) {
        return false
    }
    
    return hasProperties(lhs)
    ? propertiesAreEqual(lhs, rhs)
    : descriptionsAreEqual(lhs, rhs)
}

fileprivate func typesDiffer(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) != type(of: rhs)
}

fileprivate func hasProperties(_ candidate: Any) -> Bool {
    mirror(of: candidate).hasProperties
}

fileprivate func propertiesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    properties(of: lhs) == properties(of: rhs)
}

fileprivate func descriptionsAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    description(of: lhs) == description(of: rhs)
}

fileprivate func properties(of obj: Any) -> String {
    let objProperties = mirror(of: obj)
        .children
        .map(\.value)
        .map(childProperties)

    return description(of: objProperties)
}

fileprivate func mirror(of obj: Any) -> Mirror {
    Mirror(reflecting: obj)
}

fileprivate func description(of obj: Any) -> String {
    String(describing: obj)
}

fileprivate func childProperties(of obj: Any) -> Any {
    var isClass: Bool {
        mirror(of: obj).displayStyle == .class
    }
    
    return hasProperties(obj)
    ? properties(of: obj)
    : isClass
       ? comparableClassDescription(of: obj)
       : description(of: obj)
}

fileprivate func comparableClassDescription(of obj: Any) -> Any {    
    let description = description(of: obj)
    
    return description.isObjectValue
    ? description
    : description.className
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
    
    var isObjectValue: Bool {
        first != "<"
    }
}

