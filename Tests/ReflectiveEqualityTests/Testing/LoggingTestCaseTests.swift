import XCTest
@testable import ReflectiveEquality

final class LoggingTestCaseTests: XCTestCase, LoggingTestCase {
    
    var events: [EventTrace] = []
    
    let file = "LoggingTestCaseTests.swift"
    let event = "test".scrambled
    
    func testLog() {
        let expectedTrace = EventTrace(
            event: event,
            function: "testLog()",
            fileName: file,
            line: #line + 3
        )
        
        logEvent(event)
        XCTAssertEqual(events.count, 1)
        assertSameValue(events.first!, expectedTrace)
    }
    
    func testLogSequence() {
        let expectedTrace = EventTrace(
            event: event,
            function: "testLogSequence()",
            fileName: file,
            line: #line + 3
        )
        
        logEventSequence([event])
        XCTAssertEqual(events.count, 1)
        assertSameValue(events.first!, expectedTrace)
    }
    
    func testAssertLoggedNothingPasses() {
        assertNoEventsLogged()
    }
    
    func testAssertLoggedNothingFails() {
        XCTExpectFailure()
        logEvent(event)
        assertNoEventsLogged()
    }
    
    func testAssertLogLengthPasses() {
        assertLoggedEventCount(0)
        logEvent(event)
        assertLoggedEventCount(1)
    }
    
    func testAssertLogLengthFails() {
        XCTExpectFailure()
        logEvent(event)
        assertLoggedEventCount(0)
    }
    
    func testAssertLoggedPasses() {
        logEvent(event)
        assertLoggedEvent(event)
    }
    
    func testAssertLoggedFails() {
        let message = "Expected an item number 1, but observed only 0 item(s)."
        expectFailureMessage(toContain: message) {
            assertLoggedEvent(event)
        }
    }
    
    let eventSequence = ["test1", "test2"]
    
    func testAssertLoggedSequencePasses() {
        logEventSequence(eventSequence)
        assertLoggedEventSequence(eventSequence)
    }
    
    func testAssertLoggedSequenceFails() {
        XCTExpectFailure()
        assertLoggedEventSequence(eventSequence)
        logEventSequence(eventSequence)
        assertLoggedEventSequence(eventSequence, startingAt: 1)
    }
    
    func testAssertLoggedLastPasses() {
        logEventSequence(eventSequence)
        assertLastLoggedEvent("test2")
    }
    
    func testAssertLoggedLastFails() {
        XCTExpectFailure()
        logEventSequence(eventSequence)
        assertLastLoggedEvent("test1")
    }
    
    func testAssertLoggedLastSequencePasses() {
        logEvent(event)
        logEventSequence(eventSequence)
        assertLastLoggedEventSequence(eventSequence)
    }
    
    func testAssertLoggedLastSequenceFails() {
        XCTExpectFailure()
        logEvent(event)
        logEventSequence(eventSequence)
        assertLastLoggedEventSequence([event, "test1"])
    }
    
    let startLog = "\n**Start Log**\n\n"
    let endLog = "\n**End Log**\n"
    
    func testLogFormatter() throws {
        let expected =
        startLog +
        "| 0 | \(event) | testLogFormatter() | \(file) at line \(#line + 4) |\n" +
        "| 1 | \(event) | testLogFormatter() | \(file) at line \(#line + 4) |\n" +
        endLog
        
        logEvent(event)
        logEvent(event)

        XCTAssertEqual(events.formatted, expected)
    }
    
    func testLogFormatterWithUnequalColumns() throws {
        let expected =
        startLog +
        "| 0 | event      | testLogFormatterWithUnequalColumns() | \(file) at line \(#line + 4) |\n" +
        "| 1 | eventevent | testLogFormatterWithUnequalColumns() | \(file) at line \(#line + 4) |\n" +
        endLog
        
        logEvent("event")
        logEvent("eventevent")

        XCTAssertEqual(events.formatted, expected)
    }
}
