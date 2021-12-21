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
        print(formattedLog)
    }
    
    var formattedLog: String {
        log.enumerated().reduce("\n**Start Log**\n") { partialResult, entry in
            partialResult + "\(entry.offset), \(entry.element)"
        } + "\n**End Log**\n"
    }
}

extension XCTestCase {
    
    public func ifDifferentFrom(_ testClass: Any.Type, perform task: () -> ()) {
        if type(of: self) != testClass {
            task()
        }
    }
    
    public func performDeferred<Out>(_ action: (@escaping (Out) -> ()) -> (), completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action() { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    public func performDeferred<In, Out>(_ action: (In, @escaping (Out) -> ()) -> (), arg: In, completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action(arg) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    public func performDeferred<In1, In2, Out>(_ action: (In1, In2, @escaping (Out) -> ()) -> (), arg1: In1, arg2: In2, completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action(arg1, arg2) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    public func performDeferred(_ action: (XCTestExpectation) -> ()) {
        let e = XCTestExpectation()
        action(e)
        wait(for: [e], timeout: 0.1)
    }
}

public extension String {
    
    var scrambled: String {
        String(self.shuffled())
    }
}
