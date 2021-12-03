@testable import ReflectiveEquality
import XCTest

final class StringDescribingTests: ReflectiveEqualityTests {

    func test_instancesCanBeDescribed() {
        1  => "1"
        1.1 => "1.1"
        
        "1" => "1"
        
        (1, 1) => "(1, 1)"
        ("1", "1") => "(\"1\", \"1\")"
        
        [] => "[]"
        [1, 1] => "[1, 1]"
        [1: 1] => "[1: 1]"
    }
    
    func test_someClassesAreDescribedByNameAndID() {
        let object = String(describing: nsO)
        
        object.first! => "<"
        object.last! => ">"
        object.dropFirst().prefix(8) => "NSObject"
        object.dropFirst(9).first! => ":"
        object.dropFirst(10).first! => " "
        object.dropFirst(11).dropLast().count => "11"
    }
    
    func test_otherClassesAreDescribedByValue() {
        "Cat".ns => "Cat"
    }
    
    func test_someClassValuesAreUnexpected() {
        [1, 2].ns => """
                    (
                        1,
                        2
                    )
                    """
        [1: 2].ns => """
                    {
                        1 = 2;
                    }
                    """
    }
}

final class MirrorTests: XCTestCase { }

infix operator =>

func =>(_ actual: Any, _ expected: String) {
    XCTAssertEqual(String(describing: actual), expected)
}
