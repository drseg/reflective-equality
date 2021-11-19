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
            Mirror(reflecting: obj).children.map { $0.value }
        }
        
        let selfProperties = getProperties(self)
        let otherProperties = getProperties(other)
        
        return String(describing: selfProperties) == String(describing: otherProperties)
    }
}
