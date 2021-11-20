import XCTest
@testable import EquatableByReflection

// ignored property list?

class EquatableByReflectionTests: XCTestCase {
    
    func assertEqual(_ lhs: EquatableByReflection, _ rhs: Any) {
        XCTAssertTrue(lhs.isEqual(rhs))
    }
    
    func assertNotEqual(_ lhs: EquatableByReflection, _ rhs: Any) {
        XCTAssertFalse(lhs.isEqual(rhs))
    }
}

class EquatablesWithSimpleFields: EquatableByReflectionTests {
    
    func testDifferentTypesNotEqual() {
        struct First: EquatableByReflection {}
        struct Second {}
        
        assertNotEqual(First(), Second())
    }
    
    func testEmptyStructsEqual() {
        struct Null: EquatableByReflection {}
        
        assertEqual(Null(), Null())
    }
    
    func testEmptyClassesEqual() {
        class Null: EquatableByReflection {}
        
        assertEqual(Null(), Null())
    }
    
    func testStructsWithSingleValue() {
        struct OneField: EquatableByReflection {
            let field: Int
        }
        
        assertNotEqual(OneField(field: 1), OneField(field: 2))
        assertEqual(OneField(field: 1), OneField(field: 1))
    }
    
    func testClassesWithSingleDifferentValue() {
        class OneField: EquatableByReflection {
            let field: Int
            init(_ field: Int) { self.field = field }
        }
        
        assertNotEqual(OneField(1), OneField(2))
        assertEqual(OneField(1), OneField(1))
    }
    
    func testEnumCases() {
        enum Two: EquatableByReflection { case first, second }
        
        assertNotEqual(Two.first, Two.second)
        assertEqual(Two.first, Two.first)
    }
    
    func testEnumAssociatedValues() {
        enum OneValue: EquatableByReflection { case first(Int) }
        
        assertEqual(OneValue.first(1), OneValue.first(1))
        assertNotEqual(OneValue.first(1), OneValue.first(2))
    }
}

class EquatablesWithComplexFields: EquatableByReflectionTests {
    
    func testStructWithNSObjectEqualByPropertyValue() {
        struct NSHolder: EquatableByReflection {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testClassWithNSObjectEqualByPropertyValue() {
        class NSHolder: EquatableByReflection {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testStructWithNSObjectAndInt() {
        struct NSHolder: EquatableByReflection {
            let o = NSObject()
            let i: Int
        }
        
        assertEqual(NSHolder(i: 1), NSHolder(i: 1))
        assertNotEqual(NSHolder(i: 1), NSHolder(i: 2))
    }
    
    func testClassWithNSObjectAndInt() {
        class NSHolder: EquatableByReflection {
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
        struct NSHolder: EquatableByReflection {
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
        class NSHolder: EquatableByReflection {
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
        enum ObjectCase: EquatableByReflection { case ns(NSObject) }
        assertEqual(ObjectCase.ns(NSObject()), ObjectCase.ns(NSObject()))
    }
}
