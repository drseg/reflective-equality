import Foundation

protocol EquatableByReflection {
    func isEqual(_ other: Any) -> Bool
}

extension EquatableByReflection {
    func isEqual(_ other: Any) -> Bool {
        guard type(of: self) == type(of: other) else {
            return false
        }
        
        guard Mirror(reflecting: self).displayStyle != .enum else {
            return String(describing: self) == String(describing: other)
        }
        
        func getProperties(_ obj: Any) -> [Any] {
            Mirror(reflecting: obj)
                .children
                .map { $0.value }
                .compactMap {
                    let mirror = Mirror(reflecting: $0)
                    if mirror.children.count == 0 {
                        return mirror.displayStyle == .class ? nil : $0
                    }
                    else {
                        return $0
                        //return getProperties($0)
                    }
                }
        }
        
        let selfProperties = getProperties(self)
        let otherProperties = getProperties(other)
        
        print(selfProperties + otherProperties)
        
        return String(describing: selfProperties) == String(describing: otherProperties)
    }
}
