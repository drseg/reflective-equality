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
                
                var hasNoChildren: Bool {
                    mirror.children.count == 0
                }
                
                var isClass: Bool {
                    mirror.displayStyle == .class
                }
                
                var className: Any {
                    String(describing: o).split(separator: ":").first!.dropFirst()
                }
                
                return hasNoChildren
                ? (isClass ? className : o)
                : getProperties(o)
            }
            
            return Mirror(reflecting: obj)
                .children
                .map(\.value)
                .compactMap(getChildProperties)
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
