import Foundation

struct Equaliser {
    
    func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        var typesDiffer: Bool {
            type(of: lhs) != type(of: rhs)
        }
        
        var isEnumWithoutAssociatedValues: Bool {
            let mirror = Mirror(reflecting: lhs)
            return mirror.displayStyle == .enum && mirror.children.isEmpty
        }
        
        func properties(of obj: Any) -> [String] {
            func childProperties(of o: Any) -> Any? {
                let mirror = Mirror(reflecting: o)
                
                var isClass: Bool {
                    mirror.displayStyle == .class
                }
                
                var hasChildren: Bool {
                    mirror.children.count != 0
                }
                
                var comparableClassDescription: Any {
                    func isDescribedByValue(_ description: String) -> Bool {
                        description.first != "<"
                    }
                    
                    func getClassName(_ description: String) -> Any {
                        description.split(separator: ":").first!.dropFirst()
                    }
                    
                    let description = String(describing: o)
                    
                    return isDescribedByValue(description)
                    ? description
                    : getClassName(description)
                }
                
                return hasChildren
                ? properties(of: o)
                : (isClass ? comparableClassDescription : o)
            }
            
            let properties = Mirror(reflecting: obj)
                .children
                .map(\.value)
                .compactMap(childProperties)
            
            return properties.isEmpty
            ? [String(describing: obj)]
            : [String(describing: properties)]
        }
        
        if typesDiffer {
            return false
        }
        
        if isEnumWithoutAssociatedValues {
            return String(describing: lhs) == String(describing: rhs)
        }
        
        return properties(of: lhs) == properties(of: rhs)
    }
}
