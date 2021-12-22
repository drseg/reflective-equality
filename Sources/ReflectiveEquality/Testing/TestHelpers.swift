import XCTest

public extension XCTestCase {
    
    func assertSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #filePath, line: UInt = #line) {
        assertSameValue([lhs, rhs], file: file, line: line)
    }

    func assertNotSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #filePath, line: UInt = #line) {
        assertNotSameValue([lhs, rhs], file: file, line: line)
    }

    func assertSameValue(_ args: [Any], file: StaticString = #file, line: UInt = #line) {
        assert(XCTAssertTrue, args, generateEqualErrorMessage(args), file: file, line: line)
    }

    func assertNotSameValue(_ args: [Any], file: StaticString = #filePath, line: UInt = #line) {
        assert(XCTAssertFalse, args, generateNonEqualErrorMessage(args), file: file, line: line)
    }

    internal func assert(_ assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), _ args: [Any], _ message: String, file: StaticString = #filePath, line: UInt = #line) {
        assertion(haveSameValue(args), message, file, line)
    }
    
    func expectFailureMessage(toContain message: String, whenRunning test: () throws -> ()) {
        XCTExpectFailure { $0.description.contains(message) }
        try? test()
    }
    
    func performDeferred<Out>(_ action: (@escaping (Out) -> ()) -> (), completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action() { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred<In, Out>(_ action: (In, @escaping (Out) -> ()) -> (), arg: In, completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action(arg) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred<In1, In2, Out>(_ action: (In1, In2, @escaping (Out) -> ()) -> (), arg1: In1, arg2: In2, completion: @escaping (Out) -> ()) {
        performDeferred { e in
            action(arg1, arg2) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred(_ action: (XCTestExpectation) -> ()) {
        let e = XCTestExpectation()
        action(e)
        wait(for: [e], timeout: 0.1)
    }
}



