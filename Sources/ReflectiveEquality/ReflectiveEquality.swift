import Foundation

public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(lhs) == deepDescription(rhs)
}

fileprivate func deepDescription(_ instance: Any) -> String {
    instancesToDescribe(parent: instance).map {
        mirror($0).hasChildren
        ? deepDescription($0)
        : shallowDescription($0)
    }.joined()
}

fileprivate func instancesToDescribe(parent: Any) -> [Any] {
    mirror(parent).childInstances ??? [parent]
}

fileprivate func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

fileprivate func shallowDescription(_ instance: Any) -> String {
    let description = String(describing: instance)
    
    return instance is Stringy
    ? description
    : description.removingClassIDs
}

fileprivate extension Mirror {
    
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    var childInstances: [Any] {
        children.isEmpty
        ? superclassChildInstances
        : children.map(\.value) + superclassChildInstances
    }
    
    var superclassHasChildren: Bool {
        superclass?.hasChildren ?? false
    }
    
    var superclassChildInstances: [Any] {
        superclass?.childInstances ?? []
    }
    
    var superclass: Mirror? {
        superclassMirror
    }
}

fileprivate extension String {
    
    var removingClassIDs: String {
        removingAll(between: "0x", and: ")", " ", ",", ">")
    }
    
    func removingAll(between start: String, and ends: Character...) -> String {
        var s = self
        
        while let startRange = s.range(of: start) {
            let startIndex = startRange.lowerBound
            guard let endIndex = ends
                    .compactMap({
                        s[startIndex...].firstIndex(of: $0)
                    })
                    .sorted()
                    .first
            else { return s }
            
            s.replaceSubrange(startIndex...endIndex, with: "")
        }
        
        return s
    }
}

fileprivate protocol Stringy {}

extension String: Stringy {}
extension Substring: Stringy {}
extension NSString: Stringy {}

infix operator ???

func ???(_ lhs: [Any]?, _ rhs: [Any]) -> [Any] {
    (lhs?.isEmpty ?? true) ? rhs : lhs!
}
