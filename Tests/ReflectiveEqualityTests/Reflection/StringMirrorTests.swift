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
        String(describing: 1) ==> String(describing: 1)
    }
    
    func test_someClassesAreDescribedByClassNameAndID() {
        let description = String(describing: nsO)
        
        description.first! ==> "<"
        description.last! ==> ">"
        description.dropFirst().prefix(8) ==> "NSObject"
        description.dropFirst(9).first! ==> ":"
        description.dropFirst(10).first! ==> " "

        // address lengths are not always the same across different platforms
        let addressLength = description.dropFirst(11).dropLast().count
        XCTAssertGreaterThanOrEqual(addressLength, 11)
        XCTAssertLessThanOrEqual(addressLength, 14)
    }
    
    func test_classesDescribedByNameAreNotFullyComparable() {
        nsO !=> String(describing: nsO) // ideally should be equal by value
    }
    
    func test_classesDescribedByNameHaveComparableClassNames() {
        String(describing: nsO).prefix(9).dropFirst() ==> String(describing: nsO).prefix(9).dropFirst()
        String(describing: nsO).prefix(9).dropFirst() ==> "NSObject"
    }
    
    func test_otherClassesAreDescribedByValue_AndAreComparable() {
        "Cat".ns => "Cat"
        CGFloat(1.1) => "1.1"

        String(describing: "Cat".ns) ==> String(describing: "Cat".ns)
        String(describing: "Cat".ns) !==> String(describing: "Bat".ns)
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

        String(describing: [1, 2].ns) ==> String(describing: [1, 2].ns)
        String(describing: [1, 2].ns) !==> String(describing: [1, 3].ns)

        String(describing: [1: 2].ns) ==> String(describing: [1: 2].ns)
        String(describing: [1: 2].ns) !==> String(describing: [1: 3].ns)
    }
    
    func test_structsAreDescribedByNameAndValues_AndAreComparable() {
        struct Struct {
            let a = 1, b = "b", c = [1, 2, 3, 4, 5]
        }
        
        Struct() => "Struct(a: 1, b: \"b\", c: [1, 2, 3, 4, 5])"
        String(describing: Struct()) ==> String(describing: Struct())
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
        
        String(describing: c1) ==> String(describing: c2) // should not be equal
    }
    
    func test_customClassesDescribeTheirNamesAfterFinalDot() {
        class First {}; class Second {}
        
        func className(_ instance: Any) -> String {
            String(String(describing: instance).split(separator: ".").last!)
        }
        
        className(First()) ==> className(First())
        className(First()) !==> className(Second())
    }
    
    func test_closuresAreNotDescribedOrComparable() {
        let closure1: (Bool) -> (Bool) = { $0 }
        let closure2: (Bool, Bool) -> (Bool) = { $0 && $1 }
        
        closure1 => "(Function)"
        String(describing: closure1) ==> String(describing: closure2)
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

final class MirrorTests: XCTestCase {
    func test_inheritedPropertiesAreNotChildren() {
        class A { let a = "a" }
        class B: A { let b = "b"}

        let mirrorA = Mirror(reflecting: A())
        let mirrorB = Mirror(reflecting: B())

        mirrorA.children.count ==> 1
        mirrorB.children.count ==> 1

        mirrorA.children.first!.value => "a"
        mirrorB.children.first!.value => "b"
        mirrorB.superclassMirror!.children.first!.value => "a"
    }
    
    func test_NSAttributedStringAttributes_areNotChildren() {
        let s1 = NSMutableAttributedString(string: "Cat")
        s1.addAttribute(.font,
                        value: NSObject(),
                        range: NSRange(location: 0, length: 3))
        let mirror1 = Mirror(reflecting: s1)
        
        mirror1.children.isEmpty ==> true
        mirror1.superclassMirror!.children.isEmpty ==> true
        mirror1.superclassMirror!.superclassMirror!.children.isEmpty ==> true
    }
    
    func test_accessControlModifiersAreIrrelevant() {
        class A { private let a = "a" }
        
        Mirror(reflecting: A()).children.isEmpty ==> false
    }
    
    func test_computedVarsAreNotChildren() {
        class A { var a: String { "a" } }
        
        Mirror(reflecting: A()).children.isEmpty ==> true
    }
}

infix operator =>
infix operator ==>
infix operator !=>
infix operator !==>

func =><S: StringProtocol>(_ actual: Any, _ expected: S) {
    XCTAssertEqual(String(describing: actual), String(expected))
}

func ==><T: Equatable>(_ actual: T, expected: T) {
    XCTAssertEqual(actual, expected)
}

func !=><S: StringProtocol>(_ actual: Any, _ expected: S) {
    XCTAssertNotEqual(String(describing: actual), String(expected))
}

func !==><T: Equatable>(_ actual: T, expected: T) {
    XCTAssertNotEqual(actual, expected)
}
