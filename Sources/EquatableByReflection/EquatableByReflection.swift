import Foundation

struct Equaliser {
    
    static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        var typesDiffer: Bool {
            type(of: lhs) != type(of: rhs)
        }
        
        var isEnumWithoutAssociatedValues: Bool {
            let mirror = Mirror(reflecting: lhs)
            return mirror.displayStyle == .enum && mirror.children.isEmpty
        }
        
        func getProperties(_ obj: Any) -> [Any] {
            func getChildProperties(on o: Any) -> Any? {
                let mirror = Mirror(reflecting: o)
                
                var isClass: Bool {
                    mirror.displayStyle == .class
                }
                
                var hasNoChildren: Bool {
                    mirror.children.count == 0
                }
                
                var formattedClassDescription: Any {
                    func isDescribedByValue(_ description: String) -> Bool {
                        description.first != "<" || o is NSString
                    }
                    
                    func getClassName(_ description: String) -> Any {
                        description.split(separator: ":").first!.dropFirst()
                    }
                    
                    let description = String(describing: o)
                    
                    return isDescribedByValue(description)
                    ? description
                    : getClassName(description)
                }
                
                return hasNoChildren
                ? (isClass ? formattedClassDescription : o)
                : getProperties(o)
            }
            
            let result = Mirror(reflecting: obj)
                .children
                .map(\.value)
                .compactMap(getChildProperties)
            
            return result.isEmpty
            ? [String(describing: obj)]
            : result
        }
        
        if typesDiffer {
            return false
        }
        
        if isEnumWithoutAssociatedValues {
            return String(describing: lhs) == String(describing: rhs)
        }
        
        let lhsResult = getProperties(lhs)
        let rhsResult = getProperties(rhs)
        
        print(lhsResult)
        print(rhsResult)
        
        return String(describing: lhsResult) == String(describing: rhsResult)
    }
}
