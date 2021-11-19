import XCTest
@testable import EquatableByReflection

final class EquatableByReflectionTests: XCTestCase {
    
    func testDifferentTypesNotEqual() {
        struct First: EquatableByReflection {}
        struct Second {}
        
        XCTAssertFalse(First().isEqual(Second()))
    }
    
    func testEmptyStructsEqual() {
        struct Null: EquatableByReflection {}
        
        XCTAssertTrue(Null().isEqual(Null()))
    }
    
    func testEmptyClassesEqual() {
        class Null: EquatableByReflection {}
        
        XCTAssertTrue(Null().isEqual(Null()))
    }
    
    
    
//    func testEmptyEnumsEqual() {
//        enum Null: EquatableByReflection {}
//
//        XCTAssertTrue(Null().isEqual(Null()))
//    }
}
