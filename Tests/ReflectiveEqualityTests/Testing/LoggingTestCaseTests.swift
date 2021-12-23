import XCTest
@testable import ReflectiveEquality

final class LoggingTestCaseTests: XCTestCase, LoggingTestCase {
    var events: [EventTrace] = []
    
    let file = "LoggingTestCaseTests.swift"
    let event = "test".scrambled
    
    func eventTrace(function: String = #function, line: UInt) -> EventTrace {
        EventTrace(event: event,
                   function: function,
                   fileName: file,
                   line: line)
    }
    
    func testLog() {
        let expectedTrace = eventTrace(line: #line + 2)
        
        logEvent(event)
        XCTAssertEqual(events.count, 1)
        assertSameValue(events.first!, expectedTrace)
    }
    
    func testLogSequence() {
        let expectedTrace = eventTrace(line: #line + 2)
        
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
        assertLoggedEventCount(1)
        logEvent(event)
        assertLoggedEventCount(0)
    }
    
    func testAssertLoggedPasses() {
        logEvent(event)
        assertLoggedEvent(event)
    }
    
    func testAssertLoggedFails() {
        expectFailure(
            "Expected an item number 1, but observed only 0 item(s).",
            calling: assertLoggedEvent(event)
        )
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
    
    func testFormatter() throws {
        let expected =
"""

**Start Log**

| Index | Event  | Function        | File & Line                           |
| 0     | event  | testFormatter() | \(file + "" + "") (line \(#line + 7)) |
| 1     | event2 | testFormatter() | \(file + "" + "") (line \(#line + 7)) |

**End Log**

"""
        
        logEvent("event")
        logEvent("event2")
        
        XCTAssertEqual(events.formatted, expected)
    }
}
