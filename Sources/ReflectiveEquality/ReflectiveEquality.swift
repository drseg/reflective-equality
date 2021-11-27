import Foundation

public func haveSameValue(_ args: [Any]) -> Bool {
    args[0..<args.count - 1]
        .enumerated()
        .allSatisfy { haveSameValue($1, args[$0+1]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    guard sameType(lhs, rhs) else { return false }
    
    return hasChildren(lhs)
    ? equalByChildDescriptions(lhs, rhs)
    : equalByDescription(lhs, rhs)
}

fileprivate func sameType(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs)
}

fileprivate func hasChildren(_ instance: Any) -> Bool {
    mirror(of: instance).hasChildren
}

fileprivate func equalByChildDescriptions(_ lhs: Any, _ rhs: Any) -> Bool {
    childDescriptions(of: lhs) == childDescriptions(of: rhs)
}

fileprivate func equalByDescription(_ lhs: Any, _ rhs: Any) -> Bool {
    formattedDescription(of: lhs) == formattedDescription(of: rhs)
}

fileprivate func childDescriptions(of instance: Any) -> String {
    formattedDescription(
        of: mirror(of: instance)
            .childValues
            .map(subChildDescriptions)
    )
}

fileprivate func mirror(of instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func subChildDescriptions(of instance: Any) -> String {
    hasChildren(instance)
    ? childDescriptions(of: instance)
    : formattedDescription(of: instance)
}

fileprivate func formattedDescription(of instance: Any) -> String {
    let description = String(describing: instance)
    
    return description.isClassID
    ? description.className
    : description
}

fileprivate extension Mirror {
    
    var hasChildren: Bool {
        !children.isEmpty
    }
    
    var childValues: [Any] {
        children.map(\.value)
    }
}

fileprivate extension String {
    
    var className: String {
        String(split(separator: ":")
                .first!
                .dropFirst())
    }
    
    var isClassID: Bool {
        first == "<"
    }
}

