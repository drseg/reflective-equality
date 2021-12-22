import XCTest

public protocol TestLogger: AnyObject {

    func logEvent(_ observed: Any, function: String, file: String, line: UInt)
    func logEventSequence<C: Collection>(_ sequence: C, function: String, file: String, line: UInt)
}

public protocol TestLoggerImplementation: TestLogger {
    
    var events: [EventTrace] { get set }
}

extension TestLoggerImplementation {
    
    public func logEvent(_ observed: Any, function: String = #function, file: String = #fileID, line: UInt = #line) {
        let fileName = String(file.split(separator: "/").last!)
        let trace = EventTrace(event: observed, function: function, fileName: fileName, line: line)
        events.append(trace)
    }
    
    public func logEventSequence<C: Collection>(_ c: C, function: String = #function, file: String = #fileID, line: UInt = #line) {
        c.forEach { logEvent($0, function: function, file: file, line: line) }
    }
}

public struct EventTrace {
    
    let event: Any
    let function: String
    let fileName: String
    let line: UInt
}

public protocol LoggingTestCase: TestLoggerImplementation, XCTestCase { }

extension LoggingTestCase {
    
    public func assertNoEventsLogged(file: StaticString = #file, line: UInt = #line) {
        assertLoggedEventCount(0)
    }
    
    public func assertLoggedEventCount(_ expected: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(events.count, expected, file: file, line: line)
    }
    
    public func assertLastLoggedEvent(_ expected: Any, file: StaticString = #file, line: UInt = #line) {
        assertLoggedEvent(expected, atIndex: events.count - 1, file: file, line: line)
    }
    
    public func assertLoggedEvent(_ expected: Any, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard index < events.count else {
            XCTFail("Expected an item number \(index + 1), but observed only \(events.count) item(s).", file: file, line: line)
            return
        }
        assertSameValue(events[index].event, expected, file: file, line: line)
    }
    
    public func assertLastLoggedEventSequence<C: Collection>(_ c: C, file: StaticString = #file, line: UInt = #line) {
        assertLoggedEventSequence(c, startingAt: events.count - c.count, file: file, line: line)
    }
    
    public func assertLoggedEventSequence<C: Collection>(_ c: C, startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
        for (index, entry) in c.enumerated() {
            assertLoggedEvent(entry, atIndex: start + index, file: file, line: line)
        }
    }
    
    public func printEventLog() {
        print(events.formatted)
    }
}

extension Array where Element == EventTrace {
    
    var formatted: String {
        var columnWidths = [0, 0, 0, 0]
        
        func formatEntry(_ entry: EnumeratedSequence<Array<EventTrace>>.Element) -> String {
            let trace = entry.element
            
            let index = " \(entry.offset) "
            let event = " \(trace.event) "
            let function = " \(trace.function) "
            let fileNameAndLineNumber = " \(trace.fileName) at line \(trace.line) "
            
            columnWidths = longerOf(
                columnWidths, [index,
                               event,
                               function,
                               fileNameAndLineNumber]
            )
            
            return "|\(index)|\(event)|\(function)|\(fileNameAndLineNumber)|"
        }
        
        func padColumns(_ s: String) -> String {
            let columnDivider = "|"
            
            return s
                .split(separator: Character(columnDivider))
                .enumerated()
                .reduce(into: "")
            { partialResult, column in
                let padCount = columnWidths[column.offset] - column.element.count
                partialResult += columnDivider + column.element.rightPadded(padCount)
            } + columnDivider
        }
        
        let paddedEntries = enumerated()
            .map(formatEntry)
            .map(padColumns)
            .joined(separator: "\n")
        
        return "\n**Start Log**\n\n" + paddedEntries + "\n\n**End Log**\n"
    }

    private func longerOf(_ a: [Int], _ b: [String]) -> [Int] {
        a.enumerated().map {
            longerOf($0.element, b[$0.offset])
        }
    }
    
    private func longerOf(_ a: Int, _ b: String) -> Int {
        a > b.count ? a : b.count
    }
}

extension StringProtocol {
    
    public var scrambled: String {
        String(shuffled())
    }
    
    func rightPadded(_ count: Int) -> String {
        var s = String(self)
        for _ in 0..<count {
            s.append(" ")
        }
        return s
    }
}
