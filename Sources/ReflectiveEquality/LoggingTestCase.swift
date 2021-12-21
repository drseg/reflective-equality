import XCTest

public protocol TestLogger {

    func log(_ observed: Any)
    func logSequence(_ sequence: [Any])
}

open class LoggingTestCase: XCTestCase, TestLogger {
    
    public private (set) var log: [Any] = [Any]()
    
    public func log(_ observed: Any) {
        log.append(observed)
    }
    
    public func logSequence(_ sequence: [Any]) {
        for entry in sequence {
            log(entry)
        }
    }
    
    public func assertLoggedNothing(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(0, log.count, file: file, line: line)
    }
    
    public func assertLoggedLastSequence(_ s: [Any], startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
        assertLoggedSequence(s, startingAt: start, file: file, line: line)
        assertLoggedLast(s.last!, atIndex: start + s.count - 1, file: file, line: line)
    }
    
    public func assertLoggedSequence(_ s: [Any], startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
        for (index, entry) in s.enumerated() {
            assertLogged(entry, atIndex: start + index, file: file, line: line)
        }
    }
    
    public func assertLoggedLast(_ expected: Any, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        assertLogged(expected, atIndex: index, file: file, line: line)
        assertLogLength(index + 1)
    }
    
    public func assertLogged(_ expected: Any, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard index < log.count else {
            XCTFail("Expected an item number \(index + 1), but observed only \(log.count) item(s).", file: file, line: line)
            return
        }
        let observed = log[Int(index)]
        assertSameValue(observed, expected)
    }
    
    public func assertLogLength(_ expected: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(log.count, expected, file: file, line: line)
    }
    
    public func printLog() {
        print("\n**Start Log**\n")
        for (i, l) in log.enumerated() { print("\(i), \(l)") }
        print("\n**End Log**\n")
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
