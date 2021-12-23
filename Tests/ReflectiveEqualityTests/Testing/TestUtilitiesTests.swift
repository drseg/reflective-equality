import XCTest
@testable import ReflectiveEquality

class TestUtilitiesTests: XCTestCase {
    
    func expectDeferredFailure(
        count: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ test: () throws -> ()
    ) {
        expectFailure(count: count,
                      message: "Asynchronous wait failed",
                      file: file,
                      line: line,
                      calling: test)
    }
    
    func neverComplete(completion: (String) -> ()) {  }
    
    func completeDelayed(completion: @escaping (String) -> ()) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                completion("action")
            }
        }
    }
    
    func completeOnTime(completion: (String) -> ()) {
        completion("action")
    }
    
    func performAllDeferred(
        timeout: Double = 0.1,
        action: (@escaping (String) -> ()) -> (),
        completion: @escaping (String) -> ()
    ) {
        var args = [Int]()
        
        performDeferred(timeout: timeout,
                        action: {
            block in
            action { block($0) }
        },
                        completion: completion)
        
        performDeferred(timeout: timeout,
                        action: {
            a, block in
            args.append(a)
            action { block($0) }
        },
                        arg: 0,
                        completion: completion)
        
        performDeferred(timeout: timeout,
                        action: {
            a1, a2, block in
            args.append(contentsOf: [a1, a2])
            action { block($0) }
        },
                        arg1: 1,
                        arg2: 2,
                        completion: completion)
        
        performDeferred(timeout: timeout,
                        action: {
            a1, a2, a3, block in
            args.append(contentsOf: [a1, a2, a3])
            action { block($0) }
        },
                        arg1: 3,
                        arg2: 4,
                        arg3: 5,
                        completion: completion)
        
        performDeferred(timeout: timeout,
                        action: {
            a1, a2, a3, a4, block in
            args.append(contentsOf: [a1, a2, a3, a4])
            action { block($0) }
        },
                        arg1: 6,
                        arg2: 7,
                        arg3: 8,
                        arg4: 9,
                        completion: completion)
        
        XCTAssertEqual(args, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func testExpectFailureWithCountPassesWithCorrectCount() {
        expectFailure(count: 1, message: "failed") {
            XCTFail()
        }
    }
    
    func testExpectFailureWithCountFailsWithIncorrectCount() {
        expectFailure(message: "Unexpected failure count") {
            expectFailure(count: 0, message: "cat") {
                XCTFail("cat")
            }
        }
    }
    
    func testExpectFailureAutoclosure() {
        expectFailure(message: "failed",
                      calling: XCTFail())
    }
    
    
    func testPerformDeferredFailsIfExpectationNotFulfilled() {
        XCTExpectFailure()
        performDeferred { _ in }
    }
    
    func testPerformDeferredFailsIfExpectationTimesOut() {
        expectDeferredFailure {
            performDeferred(timeout: 0) { e in
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        e.fulfill()
                    }
                }
            }
        }
    }
    
    func testPerformDeferredPassesIfExpectationIsFulfilled() {
        performDeferred(timeout: 0) { $0.fulfill() }
    }

    func testPerformDeferredWithActionFailsIfFunctionDoesNotComplete() {
        expectDeferredFailure(count: 5) {
            performAllDeferred(timeout: 0, action: neverComplete) { _ in
                XCTFail("Should not have reached this line")
            }
        }
    }
    
    func testPerformDeferredWithActionFailsIfExpectationTimesOut() {
        expectDeferredFailure(count: 5) {
            performAllDeferred(timeout: 0, action: completeDelayed) {
                XCTAssertEqual($0, "action")
            }
        }
    }
    
    func testPerformDeferredWithActionPassesIfFunctionCompletes() {
        performAllDeferred(timeout: 0, action: completeOnTime) {
            XCTAssertEqual($0, "action")
        }
    }
}
