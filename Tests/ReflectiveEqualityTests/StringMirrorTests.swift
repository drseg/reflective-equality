@testable import ReflectiveEquality
import XCTest

final class StringDescribingTests: ReflectiveEqualityTests {

    func test_someInstancesCanBeDescribedAsExpected() {
        1  => "1"
        1.1 => "1.1"
        
        "1" => "1"
        
        (1, 1) => "(1, 1)"
        ("1", "1") => "(\"1\", \"1\")"
        
        [] => "[]"
        [1, 1] => "[1, 1]"
        [1: 1] => "[1: 1]"
    }
    
    func test_descriptionsAreComparable() {
        1 => String(describing: 1)
    }
    
    func test_someClassesAreDescribedByClassNameAndID() {
        let object = String(describing: nsO)
        
        object.first! => "<"
        object.last! => ">"
        object.dropFirst().prefix(8) => "NSObject"
        object.dropFirst(9).first! => ":"
        object.dropFirst(10).first! => " "
        object.dropFirst(11).dropLast().count => "11"
    }
    
    func test_classesDescribedByNameAreNotFullyComparable() {
        nsO !=> String(describing: nsO) // ideally should be equal by value
    }
    
    func test_classesDescribedByNameHaveComparableClassNames() {
        String(describing: nsO).prefix(9).dropFirst() => String(describing: nsO).prefix(9).dropFirst()
        String(describing: nsO).prefix(9).dropFirst() => "NSObject"
    }
    
    func test_otherClassesAreDescribedByValue_AndAreComparable() {
        "Cat".ns => "Cat"
        CGFloat(1.1) => "1.1"
    
        "Cat".ns => String(describing: "Cat".ns)
        "Cat".ns !=> String(describing: "Bat".ns)
    }
    
    func test_someClassValuesAreUnexpected_YetRemainComparable() {
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
    
        [1, 2].ns => String(describing: [1, 2].ns)
        [1, 2].ns !=> String(describing: [1, 3].ns)
        
        [1: 2].ns => String(describing: [1: 2].ns)
        [1: 2].ns !=> String(describing: [1: 3].ns)
    }
    
    func test_structsAreDescribedByNameAndValues_AndAreComparable() {
        struct Struct {
            let a = 1, b = "b", c = [1, 2, 3, 4, 5]
        }
        
        Struct() => "Struct(a: 1, b: \"b\", c: [1, 2, 3, 4, 5])"
        Struct() => String(describing: Struct())
    }
    
    func test_customClassesAreOpaquelyDescribed_AndNotComparable() {
        class CustomClass {
            let a: Int, b: String, c: [Int]
            
            init(_ a: Int, _ b: String, _ c: [Int]) {
                self.a = a
                self.b = b
                self.c = c
            }
        }
        
        let c1 = CustomClass(1, "b", [1, 2, 3, 4, 5])
        let c2 = CustomClass(2, "c", [2, 3, 4, 5, 6])
        
        c1 => String(describing: c2) // should not be equal
    }
    
    func test_customClassesDescribeTheirNamesAfterFinalDot() {
        class First {}; class Second {}
        
        func className(_ instance: Any) -> String {
            String(String(describing: instance).split(separator: ".").last!)
        }
        
        XCTAssertEqual(className(First()), className(First()))
        XCTAssertNotEqual(className(First()), className(Second()))
    }
    
    func test_closuresAreNotDescribedOrComparable() {
        let closure1: (Bool) -> (Bool) = { $0 }
        let closure2: (Bool, Bool) -> (Bool) = { $0 && $1 }
        
        closure1 => "(Function)"
        closure1 => String(describing: closure2)
    }
    
    func test_enumsAreDescribedByCaseName() {
        enum Enum { case a, b }
        
        Enum.a => "a"
        Enum.b => "b"
    }
    
    func test_enumsWithAssociatedValuesAreDescribedByCaseNameAndValue() {
        enum Enum { case a(Int), b(Int) }
        
        Enum.a(1) => "a(1)"
        Enum.b(2) => "b(2)"
    }
}

final class MirrorTests: XCTestCase { }

infix operator =>
infix operator !=>

func =><S: StringProtocol>(_ actual: Any, _ expected: S) {
    XCTAssertEqual(String(describing: actual), String(expected))
}

func !=><S: StringProtocol>(_ actual: Any, _ expected: S) {
    XCTAssertNotEqual(String(describing: actual), String(expected))
}
