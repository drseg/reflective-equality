import XCTest
@testable import EquatableByReflection

// ignored property list?

class EquatableByReflectionTests: XCTestCase {
    
    func assertEqual(_ lhs: Any, _ rhs: Any) {
        assert(lhs, rhs, assertion: XCTAssertTrue)
    }
    
    func assertNotEqual(_ lhs: Any, _ rhs: Any) {
        assert(lhs, rhs, assertion: XCTAssertFalse)
    }
    
    func assert(_ lhs: Any, _ rhs: Any, assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), file: StaticString = #file, line: UInt = #line) {
        assertion(Equaliser.isEqual(lhs, rhs),
                  "\nLHS: \(String(describing: lhs))\nRHS: \(String(describing: rhs))", file, line)
    }
}

class SimpleFoundationTests: EquatableByReflectionTests {
    
    func testEqualArrays() {
        assertEqual([], [])
        assertEqual([1], [1])
        assertEqual([1, 2], [1, 2])
        assertEqual([[1, 2], [1, 2]], [[1, 2], [1, 2]])
    }
    
    func testNonEqualArrays() {
        assertNotEqual([], [1])
        assertNotEqual([1], [2])
        assertNotEqual([1, 2], [1, 3])
        assertNotEqual([[1, 2], [1, 2]], [[1, 2], [1, 3]])
    }
    
    func testEqualDictionaries() {
        assertEqual([:], [:])
        assertEqual(["1": 1], ["1": 1])
        assertEqual(["1": ["1": 1]], ["1": ["1": 1]])
    }
    
    func testNonEqualDictionaries() {
        assertNotEqual([:], ["1": 1])
        assertNotEqual(["1": 1], ["1": 2])
        assertNotEqual(["1": 1], ["2": 1])
    }

    var none            :  Any { Optional<Int>.none     as Any }
    func some(_ i: Int) -> Any { Optional<Int>.some(i)  as Any }
    
    func testEqualOptionals() {
        assertEqual(none, none)
        assertEqual(some(1), some(1))
    }
    
    func testNonEqualOptionals() {
        assertNotEqual(some(1), none)
        assertNotEqual(some(1), some(2))
    }
}

class ComplexFoundationTests: EquatableByReflectionTests {

    var nsO: NSObject { NSObject() }
    
    func testArrayOfNSObject() {
        assertEqual([nsO], [nsO])
        assertEqual([[nsO]], [[nsO]])
        
        assertNotEqual([[nsO]], [[nsO, nsO]])
    }
    
    func testDictionaryOfNSObject() {
        assertEqual([nsO: 1], [nsO: 1])
        assertEqual([nsO: nsO], [nsO: nsO])
        
        assertNotEqual([nsO: [nsO]], [nsO: [nsO, nsO]])
        assertNotEqual([nsO: 1], [nsO: 2])
    }
    
    func testPolymorphicCollections() {
        class A: NSObject {}
        class B: NSObject {}
        
        assertEqual([A()], [A()])
        assertNotEqual([A()], [B()])
        
        assertEqual([A(): B()], [A(): B()])
        assertEqual([B(): A()], [B(): A()])
        
        assertNotEqual([B(): A()], [B(): B()])
        assertNotEqual([A(): A()], [B(): A()])
    }
    
    func testNSCollections() {
        let a = [1, 2, 3, 4, 5]
        let b = a
        let c = a + [6]
        
        let nsA = a as NSArray
        let nsB = b as NSArray
        let nsC = c as NSArray
        
        assertEqual(nsA, nsB)
        assertNotEqual(nsA, nsC)
    }
}

class SimpleCompositionTests: EquatableByReflectionTests {
    
    func testDifferentTypesNotEqual() {
        struct First {}
        struct Second {}
        
        assertNotEqual(First(), Second())
    }
    
    func testEmptyStructsEqual() {
        struct Null {}
        
        assertEqual(Null(), Null())
    }
    
    func testEmptyClassesEqual() {
        class Null {}
        
        assertEqual(Null(), Null())
    }
    
    func testStructsWithSingleValue() {
        struct OneField {
            let field: Int
        }
        
        assertNotEqual(OneField(field: 1), OneField(field: 2))
        assertEqual(OneField(field: 1), OneField(field: 1))
    }
    
    func testClassesWithSingleDifferentValue() {
        class OneField {
            let field: Int
            init(_ field: Int) { self.field = field }
        }
        
        assertNotEqual(OneField(1), OneField(2))
        assertEqual(OneField(1), OneField(1))
    }
    
    func testEnumCases() {
        enum Two { case first, second }
        
        assertNotEqual(Two.first, Two.second)
        assertEqual(Two.first, Two.first)
    }
    
    func testEnumAssociatedValues() {
        enum OneValue { case first(Int) }
        
        assertEqual(OneValue.first(1), OneValue.first(1))
        assertNotEqual(OneValue.first(1), OneValue.first(2))
    }
}

class ComplexCompositionTests: EquatableByReflectionTests {
    
    func testStructWithNSObjectEqualByPropertyValue() {
        struct NSHolder {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testClassWithNSObjectEqualByPropertyValue() {
        class NSHolder {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testStructWithNSObjectAndInt() {
        struct NSHolder {
            let o = NSObject()
            let i: Int
        }
        
        assertEqual(NSHolder(i: 1), NSHolder(i: 1))
        assertNotEqual(NSHolder(i: 1), NSHolder(i: 2))
    }
    
    func testClassWithNSObjectAndInt() {
        class NSHolder {
            let o = NSObject()
            let i: Int
            
            init(i: Int) { self.i = i }
        }
        
        assertEqual(NSHolder(i: 1), NSHolder(i: 1))
        assertNotEqual(NSHolder(i: 1), NSHolder(i: 2))
    }

    struct Nested {
        let i: Int
        let o = NSObject()
    }
    
    func testStructWithNestedStruct() {
        struct NSHolder {
            let o = NSObject()
            let i: Int
            let n: Nested
            
            init(i: Int, n: Nested) {
                self.i = i
                self.n = n
            }
        }
        
        let h1 = NSHolder(i: 1, n: Nested(i: 1))
        let h2 = NSHolder(i: 1, n: Nested(i: 1))
        let h3 = NSHolder(i: 1, n: Nested(i: 2))
        
        assertEqual(h1, h2)
        assertNotEqual(h1, h3)
    }
    
    func testClassWithNestedStruct() {
        class NSHolder {
            let o = NSObject()
            let i: Int
            let n: Nested
            
            init(i: Int, n: Nested) {
                self.i = i
                self.n = n
            }
        }
        
        let h1 = NSHolder(i: 1, n: Nested(i: 1))
        let h2 = NSHolder(i: 1, n: Nested(i: 1))
        let h3 = NSHolder(i: 1, n: Nested(i: 2))
        
        assertEqual(h1, h2)
        assertNotEqual(h1, h3)
    }
    
    func testEnumWithAssociatedNSObject() {
        enum ObjectCase { case ns(NSObject) }
        
        assertEqual(ObjectCase.ns(NSObject()), ObjectCase.ns(NSObject()))
    }
}
