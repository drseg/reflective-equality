import Foundation
import ObjCReflection

public func haveSameValue(_ args: [Any]) -> Bool {
    args.allSatisfy { haveSameValue($0, args[0]) }
}

public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool {
    type(of: lhs) == type(of: rhs) &&
    deepDescription(lhs) == deepDescription(rhs)
}

func deepDescription(_ instance: Any) -> String {
    swiftInstancesToDescribe(parent: instance).map {
        mirror($0).hasChildren
        ? deepDescription($0)
        : shallowDescription($0)
        + deepObjcDescription(parent: $0)
    }.joined()
}

func deepObjcDescription(parent: Any) -> String {
    guard let parent = parent as? NSObject else { return "" }
    
    return parent
        .propertyValues
        .map(shallowDescription)
        .joined()
}

func swiftInstancesToDescribe(parent: Any) -> [Any] {
    mirror(parent).childInstances ??? [parent]
}

func mirror(_ instance: Any) -> Mirror {
    Mirror(reflecting: instance)
}

func shallowDescription(_ instance: Any) -> String {
    let description = String(describing: instance)
    
    return instance is Stringy
    ? description
    : description.removingClassIDs
}

extension Mirror {
    
    var hasChildren: Bool {
        children.isEmpty
        ? superclassHasChildren
        : true
    }

    var superclassHasChildren: Bool {
        superclassMirror?.hasChildren ?? false
    }
    
    var childInstances: [Any] {
        children.map(\.value) + superclassChildInstances
    }
    
    var superclassChildInstances: [Any] {
        superclassMirror?.childInstances ?? []
    }
}

extension String {
    
    var removingClassIDs: String {
        removingMatches("[ =(]0x[0-9a-f]{\(hexLength)}")
    }
    
    var hexLength: Int {
        NSObject().description.count - "<NSObject: 0x>".count
    }
    
    func removingMatches(_ regex: String) -> String {
        replacingOccurrences(of: regex,
                             with: "",
                             options: .regularExpression)
    }
}

protocol Stringy {}

extension String: Stringy {}
extension Substring: Stringy {}
extension NSString: Stringy {}

infix operator ???

func ???(_ lhs: [Any]?, _ rhs: [Any]) -> [Any] {
    (lhs?.isEmpty ?? true) ? rhs : lhs!
}
