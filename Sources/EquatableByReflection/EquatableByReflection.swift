import Foundation

protocol EquatableByReflection {
    func isEqual(_ other: Any) -> Bool
}

extension EquatableByReflection {
    func isEqual(_ other: Any) -> Bool {
        var areSameType: Bool {
            type(of: self) == type(of: other)
        }
        
        var isNotEnumWithoutAssociatedValues: Bool {
            let mirror = Mirror(reflecting: self)
            return mirror.displayStyle != .enum || !mirror.children.isEmpty
        }
        
        guard areSameType else {
            return false
        }
        
        guard isNotEnumWithoutAssociatedValues else {
            return String(describing: self) == String(describing: other)
        }
        
        func getProperties(_ obj: Any) -> [Any] {
            func getChildProperties(on o: Any) -> Any? {
                let mirror = Mirror(reflecting: o)
                let hasNoChildren = mirror.children.count == 0
                let isClass = mirror.displayStyle == .class
                
                if hasNoChildren {
                    return isClass ? nil : o
                }
                else {
                    return getProperties(o)
                }
            }
            
            return Mirror(reflecting: obj)
                .children
                .map(\.value)
                .compactMap(getChildProperties)
        }
        
        return String(describing: getProperties(self)) == String(describing: getProperties(other))
    }
}
