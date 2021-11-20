import XCTest
@testable import EquatableByReflection

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
    
}
