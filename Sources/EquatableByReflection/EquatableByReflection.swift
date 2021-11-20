import Foundation

struct Equaliser {
    
    func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        if typesDiffer(lhs, rhs) {
            return false
        }
        
        if isEnumWithoutAssociatedValues(lhs) {
            return String(describing: lhs) == String(describing: rhs)
        }
        
        return properties(of: lhs) == properties(of: rhs)
    }
    
    private func typesDiffer(_ lhs: Any, _ rhs: Any) -> Bool {
        type(of: lhs) != type(of: rhs)
    }
    
    private func isEnumWithoutAssociatedValues(_ candidate: Any) -> Bool {
        let mirror = Mirror(reflecting: candidate)
        return mirror.displayStyle == .enum && mirror.children.isEmpty
    }
    
    private func properties(of obj: Any) -> [String] {
        let properties = Mirror(reflecting: obj)
            .children
            .map(\.value)
            .compactMap(childProperties)
        
        return properties.isEmpty
        ? [String(describing: obj)]
        : [String(describing: properties)]
    }
    
    private func childProperties(of obj: Any) -> Any? {
        let mirror = Mirror(reflecting: obj)
        
        var isClass: Bool {
            mirror.displayStyle == .class
        }
        
        var hasChildren: Bool {
            mirror.children.count != 0
        }
        
        return hasChildren
        ? properties(of: obj)
        : (isClass ? comparableClassDescription(of: obj) : obj)
    }
    
    private func comparableClassDescription(of obj: Any) -> Any {
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
}
