import XCTest
@testable import ReflectiveEquality

final class LoggingTestCaseTests: LoggingTestCase {
    
    func testLog() {
        log("test")
        XCTAssertEqual(log.count, 1)
        assertSameValue(log.first!, "test")
    }
    
    func testLogSequence() {
        logSequence(["test"])
        XCTAssertEqual(log.count, 1)
        assertSameValue(log.first!, "test")
    }
    
    func testAssertLoggedNothingPasses() {
        assertLoggedNothing()
    }
    
    func testAssertLoggedNothingFails() {
        XCTExpectFailure()
        log("test")
        assertLoggedNothing()
    }
    
    func testAssertLogLengthPasses() {
        assertLogLength(0)
        log("test")
        assertLogLength(1)
    }
    
    func testAssertLogLengthFails() {
        XCTExpectFailure()
        log("test")
        assertLogLength(0)
    }
    
    func testAssertLoggedPasses() {
        log("test")
        assertLogged("test")
    }
    
    func testAssertLoggedFails() {
        let message = "Expected an item number 1, but observed only 0 item(s)."
        expectFailureMessage(containing: message) {
            assertLogged("test")
        }
    }
    
    let testSequence = ["test1", "test2"]
    
    func testAssertLoggedSequencePasses() {
        logSequence(testSequence)
        assertLoggedSequence(testSequence)
    }
    
    func testAssertLoggedSequenceFails() {
        XCTExpectFailure()
        assertLoggedSequence(testSequence)
        logSequence(testSequence)
        assertLoggedSequence(testSequence, startingAt: 1)
    }
    
    func testAssertLoggedLastPasses() {
        logSequence(testSequence)
        assertLoggedLast("test2")
    }
    
    func testAssertLoggedLastFails() {
        XCTExpectFailure()
        logSequence(testSequence)
        assertLoggedLast("test1")
    }
    
    func testAssertLoggedLastSequencePasses() {
        log("test")
        logSequence(testSequence)
        assertLoggedLastSequence(testSequence)
    }
    
    func testAssertLoggedLastSequenceFails() {
        XCTExpectFailure()
        log("test")
        logSequence(testSequence)
        assertLoggedLastSequence(["test", "test1"])
    }
    
    func testLogFormatter() {
        let expected =
        "\n**Start Log**\n" +
        "0, test" +
        "\n**End Log**\n"
        
        log("test")
        XCTAssertEqual(log.formatted, expected)
    }
}
