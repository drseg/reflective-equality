import XCTest
@testable import ReflectiveEquality

class AbstractTestCaseBaseTests: AbstractTestCase {
    var shouldFail = true
    
    public override class var abstractBaseClass: Any.Type {
        AbstractTestCaseBaseTests.self
    }
    
    func testAbstractlyOnlyRunsInSubclasses() {
        if shouldFail {
            XCTFail()
        }
    }
    
    func testOtherwiseRunsInAll() {
        XCTAssertTrue(true)
    }
}

class AbstractTestCaseSubTests: AbstractTestCaseBaseTests {
    
    override func setUp() {
        shouldFail = false
    }
}
