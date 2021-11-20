import Foundation

protocol EquatableByReflection {
    func isEqual(_ other: Any) -> Bool
}

extension EquatableByReflection {
    func isEqual(_ other: Any) -> Bool {
        var typesDiffer: Bool {
            type(of: self) != type(of: other)
        }
        
        var isEnumWithoutAssociatedValues: Bool {
            let mirror = Mirror(reflecting: self)
            return mirror.displayStyle == .enum && mirror.children.isEmpty
        }
        
        func getProperties(_ obj: Any) -> [Any] {
            func getChildProperties(on o: Any) -> Any? {
                let mirror = Mirror(reflecting: o)
                let hasNoChildren = mirror.children.count == 0
                let isClass = mirror.displayStyle == .class
                
                return hasNoChildren
                    ? (isClass ? nil : o)
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
            return String(describing: self) == String(describing: other)
        }
        
        return String(describing: getProperties(self)) == String(describing: getProperties(other))
    }
}
