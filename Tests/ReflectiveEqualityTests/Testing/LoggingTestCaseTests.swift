import XCTest
@testable import ReflectiveEquality

final class LoggingTestCaseTests: XCTestCase, LoggingTestCase {
    var events: [EventTrace] = []
    
    let file = "LoggingTestCaseTests.swift"
    let event = "test".scrambled
    
    func eventTrace(
        function: String = #function,
        line: UInt
    ) -> EventTrace {
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
            when: assertLoggedEvent(event)
        )
    }
    
    let sequence = ["test1", "test2"]
    
    func testAssertLoggedSequencePasses() {
        logEventSequence(sequence)
        assertLoggedEventSequence(sequence)
    }
    
    func testAssertLoggedSequenceFails() {
        XCTExpectFailure()
        assertLoggedEventSequence(sequence)
        logEventSequence(sequence)
        assertLoggedEventSequence(sequence, startingAt: 1)
    }
    
    func testAssertLoggedLastPasses() {
        logEventSequence(sequence)
        assertLastLoggedEvent("test2")
    }
    
    func testAssertLoggedLastFails() {
        XCTExpectFailure()
        logEventSequence(sequence)
        assertLastLoggedEvent("test1")
    }
    
    func testAssertLoggedLastSequencePasses() {
        logEvent(event)
        logEventSequence(sequence)
        assertLastLoggedEventSequence(sequence)
    }
    
    func testAssertLoggedLastSequenceFails() {
        XCTExpectFailure()
        logEvent(event)
        logEventSequence(sequence)
        assertLastLoggedEventSequence([event, "test1"])
    }
    
    func testFormatter() {
        let expected =
"""

**Start Log**

| i | Event  | Function        | File & Line                    |
| 0 | event  | testFormatter() | \(file + "" + ""):\(#line + 7) |
| 1 | event2 | testFormatter() | \(file + "" + ""):\(#line + 7) |

**End Log**

"""
        
        logEvent("event")
        logEvent("event2")
        
        XCTAssertEqual(events.formatted, expected)
    }
}
