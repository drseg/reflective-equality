import XCTest

public extension XCTestCase {
    func expectFailure(
        count: Int? = nil,
        message: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        calling test: () throws -> ()
    ) {
        try expectFailure(count: count,
                          message: message,
                          file: file,
                          line: line,
                          calling: test())
    }
    
    func expectFailure(
        count: Int? = nil,
        message: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        calling test: @autoclosure () throws -> ()
    ) {
        var failureCount = 0
        XCTExpectFailure {
            failureCount += 1
            return $0.description.contains(message)
        }
        try? test()
        
        if let count = count {
            XCTAssertEqual(count, failureCount,
                           "Unexpected failure count",
                           file: file,
                           line: line)
        }
    }
    
    func performDeferred<Out>(
        timeout: Double = 0.1,
        action: (@escaping (Out) -> ()) -> (),
        completion: @escaping (Out) -> ()
    ) {
        performDeferred(timeout: timeout) { e in
            action() { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred<In, Out>(
        timeout: Double = 0.1,
        action: (In, @escaping (Out) -> ()) -> (),
        arg: In,
        completion: @escaping (Out) -> ()
    ) {
        performDeferred(timeout: timeout) { e in
            action(arg) { result in
                e.fulfill()
                completion(result)
            }
        }
    }

    func performDeferred<In1, In2, Out>(
        timeout: Double = 0.1,
        action: (In1, In2, @escaping (Out) -> ()) -> (),
        arg1: In1,
        arg2: In2,
        completion: @escaping (Out) -> ()
    ) {
        performDeferred(timeout: timeout) { e in
            action(arg1, arg2) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred<In1, In2, In3, Out>(
        timeout: Double = 0.1,
        action: (In1, In2, In3, @escaping (Out) -> ()) -> (),
        arg1: In1,
        arg2: In2,
        arg3: In3,
        completion: @escaping (Out) -> ()
    ) {
        performDeferred(timeout: timeout) { e in
            action(arg1, arg2, arg3) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred<In1, In2, In3, In4, Out>(
        timeout: Double = 0.1,
        action: (In1, In2, In3, In4, @escaping (Out) -> ()) -> (),
        arg1: In1,
        arg2: In2,
        arg3: In3,
        arg4: In4,
        completion: @escaping (Out) -> ()
    ) {
        performDeferred(timeout: timeout) { e in
            action(arg1, arg2, arg3, arg4) { result in
                e.fulfill()
                completion(result)
            }
        }
    }
    
    func performDeferred(
        timeout: Double = 0.1,
        _ action: (XCTestExpectation) -> ()
    ) {
        let e = XCTestExpectation()
        action(e)
        wait(for: [e], timeout: timeout)
    }
}



