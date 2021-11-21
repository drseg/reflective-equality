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
    !Mirror(reflecting: candidate).children.isEmpty
}

fileprivate func descriptionsAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    description(of: lhs) == description(of: rhs)
}

fileprivate func propertiesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    properties(of: lhs) == properties(of: rhs)
}

fileprivate func properties(of obj: Any) -> String {
    let objProperties = Mirror(reflecting: obj)
        .children
        .map(\.value)
        .map(childProperties)

    return description(of: objProperties)
}

fileprivate func description(of obj: Any) -> String {
    String(describing: obj)
}

fileprivate func childProperties(of obj: Any) -> Any {
    let mirror = Mirror(reflecting: obj)
    
    var isClass: Bool {
        mirror.displayStyle == .class
    }
    
    return hasProperties(obj)
    ? properties(of: obj)
    : isClass
       ? comparableClassDescription(of: obj)
       : description(of: obj)
}

fileprivate func comparableClassDescription(of obj: Any) -> Any {
    func isDescribedByValue(_ description: String) -> Bool {
        description.first != "<"
    }
    
    func getClassName(_ description: String) -> Any {
        description.split(separator: ":").first!.dropFirst()
    }
    
    let description = String(describing: obj)
    
    return isDescribedByValue(description)
    ? description
    : getClassName(description)
}

