import XCTest

public protocol TestLogger {
    func logEvent(
        _ observed: Any,
        function: String,
        file: String,
        line: UInt
    )
    
    func logEventSequence<C>(
        _ sequence: C,
        function: String,
        file: String,
        line: UInt
    ) where C: Collection
}

public protocol LoggingTestCase: TestLogger, XCTestCase {
    var events: [EventTrace] { get set }
}


public struct EventTrace {
    let event: Any
    let function: String
    let fileName: String
    let line: UInt
}

public extension LoggingTestCase {
    func logEvent(
        _ observed: Any,
        function: String = #function,
        file: String = #fileID,
        line: UInt = #line
    ) {
        let fileName = String(file.split(separator: "/").last!)
        let trace = EventTrace(event: observed,
                               function: function,
                               fileName: fileName,
                               line: line)
        events.append(trace)
    }
    
    func logEventSequence<C: Collection>(
        _ collection: C,
        function: String = #function,
        file: String = #fileID,
        line: UInt = #line
    ) {
        collection.forEach {
            logEvent($0,
                     function: function,
                     file: file,
                     line: line)
        }
    }
    
    func assertNoEventsLogged(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertLoggedEventCount(0)
    }
    
    func assertLoggedEventCount(
        _ expected: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(events.count,
                       expected,
                       file: file,
                       line: line)
    }
    
    func assertLastLoggedEvent(
        _ expected: Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertLoggedEvent(expected,
                          atIndex: events.count - 1,
                          file: file,
                          line: line)
    }
    
    func assertLoggedEvent(
        _ expected: Any,
        atIndex index: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard index < events.count else {
            let message =
            "Expected an item number \(index + 1), " +
            "but observed only \(events.count) item(s)."
            XCTFail(message, file: file, line: line)
            return
        }
        assertSameValue(events[index].event, expected,
                        file: file,
                        line: line)
    }
    
    func assertLastLoggedEventSequence<C: Collection> (
        _ collection: C,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertLoggedEventSequence(collection,
                                  startingAt: events.count - collection.count,
                                  file: file,
                                  line: line)
    }
    
    func assertLoggedEventSequence<C: Collection>(
        _ collection: C,
        startingAt start: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for (i, event) in collection.enumerated() {
            assertLoggedEvent(event,
                              atIndex: start + i,
                              file: file,
                              line: line)
        }
    }
    
    func printEventLog() {
        print(events.formatted)
    }
}

extension Collection where Element == EventTrace {
    var formatted: String {
        func formatEntry(_ entry: (i: Int, et: EventTrace)) -> String {
            let trace = entry.et
            
            let index = " \(entry.i) "
            let event = " \(trace.event) "
            let function = " \(trace.function) "
            let fileAndLine = " \(trace.fileName) (line \(trace.line)) "
            
            columnWidths = max(columnWidths, [index,
                                              event,
                                              function,
                                              fileAndLine]
            )
            
            return "|\(index)|\(event)|\(function)|\(fileAndLine)|"
        }
        
        func padColumns(_ row: String) -> String {
            func padColumn(
                _ columns: inout String,
                _ column: (Int, String.SubSequence)
            ) {
                let padCount = columnWidths[column.0] - column.1.count
                columns += divider + column.1.rightPadded(padCount)
            }
            
            return row
                .split(separator: Character(divider))
                .enumerated()
                .reduce(into: "", padColumn) + divider
        }
        
        let header = "| Index | Event | Function | File & Line |"
        let divider = "|"
        var columnWidths = header
            .split(separator: Character(divider))
            .map(\.count)
        
        let formattedEntries = [header] + enumerated().map(formatEntry)
        let paddedEntries = formattedEntries
            .map(padColumns)
            .joined(separator: "\n")
        
        return "\n**Start Log**\n\n" + paddedEntries + "\n\n**End Log**\n"
    }

    private func max(_ a: [Int], _ b: [String]) -> [Int] {
        a.enumerated().map {
            max($0.element, b[$0.offset])
        }
    }
    
    private func max(_ a: Int, _ b: String) -> Int {
        a > b.count ? a : b.count
    }
}

extension StringProtocol {
    public var scrambled: String {
        String(shuffled())
    }
    
    func rightPadded(_ count: Int) -> String {
        self + String(repeating: " ", count: count)
    }
}
