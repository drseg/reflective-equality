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
    
    func testStructsWithSingleDifferentValueNotEqual() {
        struct OneField: EquatableByReflection {
            let field: Int
        }
        
        assertNotEqual(OneField(field: 1), OneField(field: 2))
    }
    
    func testStructsWithSingleEqualValueEqual() {
        struct OneField: EquatableByReflection {
            let field = 1
        }
        
        assertEqual(OneField(), OneField())
    }
    
    func testClassesWithSingleDifferentValueNotEqual() {
        class OneField: EquatableByReflection {
            let field: Int
            init(_ field: Int) { self.field = field }
        }
        
        assertNotEqual(OneField(1), OneField(2))
    }
    
    func testSingleEnumCasesEqual() {
        enum Null: EquatableByReflection { case single }
        
        assertEqual(Null.single, Null.single)
    }
    
    func testDifferentEnumCasesNotEqual() {
        enum Two: EquatableByReflection { case first, second }
        
        assertNotEqual(Two.first, Two.second)
    }
    
    enum Single: EquatableByReflection { case first(Int) }
    
    func testEqualAssociatedValuesEqual() {
        assertEqual(Single.first(1), Single.first(1))
    }
    
    func testSameEnumCaseWithDifferentValuesNotEqual() {
        assertNotEqual(Single.first(1), Single.first(2))
    }
}
