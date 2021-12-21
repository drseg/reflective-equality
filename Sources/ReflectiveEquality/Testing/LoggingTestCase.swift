import XCTest

public protocol TestLogger {

    func log(_ observed: Any)
    func logSequence<C: Collection>(_ sequence: C)
}

open class LoggingTestCase: XCTestCase, TestLogger {
    
    public private (set) var log = [Any]()
    
    public func log(_ observed: Any) {
        log.append(observed)
    }
    
    public func logSequence<C: Collection>(_ c: C) {
        c.forEach(log)
    }
    
    public func assertLoggedNothing(file: StaticString = #file, line: UInt = #line) {
        assertLogLength(0)
    }
    
    public func assertLogLength(_ expected: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(log.count, expected, file: file, line: line)
    }
    
    public func assertLoggedLast(_ expected: Any, file: StaticString = #file, line: UInt = #line) {
        assertLogged(expected, atIndex: log.count - 1, file: file, line: line)
    }
    
    public func assertLogged(_ expected: Any, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard index < log.count else {
            XCTFail("Expected an item number \(index + 1), but observed only \(log.count) item(s).", file: file, line: line)
            return
        }
        assertSameValue(log[index], expected, file: file, line: line)
    }
    
    public func assertLoggedLastSequence<C: Collection>(_ c: C, file: StaticString = #file, line: UInt = #line) {
        assertLoggedSequence(c, startingAt: log.count - c.count, file: file, line: line)
    }
    
    public func assertLoggedSequence<C: Collection>(_ c: C, startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
        for (index, entry) in c.enumerated() {
            assertLogged(entry, atIndex: start + index, file: file, line: line)
        }
    }
    
    public func printLog() {
        print(log.formatted)
    }
}

extension Array {
    
    var formatted: String {
        enumerated().reduce("\n**Start Log**\n") { partialResult, entry in
            partialResult + "\(entry.offset), \(entry.element)"
        } + "\n**End Log**\n"
    }
}

public extension String {
    
    var scrambled: String {
        String(shuffled())
    }
}
