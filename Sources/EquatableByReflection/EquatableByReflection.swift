protocol EquatableByReflection {
    func isEqual(_ other: Any) -> Bool
}

extension EquatableByReflection {
    func isEqual(_ other: Any) -> Bool {
        guard type(of: self) == type(of: other) else {
            return false
        }
        return true
    }
}
