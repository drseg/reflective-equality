import XCTest
@testable import ReflectiveEquality

class TestUtilitiesTests: XCTestCase {
    
    func expectDeferredFailure(
        count: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ test: () throws -> ()
    ) {
        expectFailure("Asynchronous wait failed",
                      count: count,
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
        action: (@escaping (String) -> ()) -> (),
        completion: @escaping (String) -> ()
    ) {
        var args = [Int]()
        
        performDeferred(timeout: 0,
                        action: {
            block in
            action { block($0) }
        },
                        completion: completion)
        
        performDeferred(timeout: 0,
                        action: {
            a, block in
            args.append(a)
            action { block($0) }
        },
                        arg: 0,
                        completion: completion)
        
        performDeferred(timeout: 0,
                        action: {
            a1, a2, block in
            args.append(contentsOf: [a1, a2])
            action { block($0) }
        },
                        arg1: 1,
                        arg2: 2,
                        completion: completion)
        
        performDeferred(timeout: 0,
                        action: {
            a1, a2, a3, block in
            args.append(contentsOf: [a1, a2, a3])
            action { block($0) }
        },
                        arg1: 3,
                        arg2: 4,
                        arg3: 5,
                        completion: completion)
        
        performDeferred(timeout: 0,
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
        
        XCTAssertEqual(args, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
                       "performDeferred did not pass its arguments correctly")
    }
    
    func testExpectFailureWithCountPassesWithCorrectCount() {
        expectFailure("failed", count: 1) {
            XCTFail()
        }
    }
    
    func testExpectFailureWithCountFailsWithIncorrectCount() {
        expectFailure("Unexpected failure count") {
            expectFailure("cat", count: 0) {
                XCTFail("cat")
            }
        }
    }
    
    func testExpectFailureAutoclosure() {
        expectFailure("failed",
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
            performAllDeferred(action: neverComplete) { _ in
                XCTFail("Should not have reached this line")
            }
        }
    }
    
    func testPerformDeferredWithActionFailsIfExpectationTimesOut() {
        expectDeferredFailure(count: 5) {
            performAllDeferred(action: completeDelayed) {
                XCTAssertEqual($0, "action")
            }
        }
    }
    
    func testPerformDeferredWithActionPassesIfFunctionCompletes() {
        performAllDeferred(action: completeOnTime) {
            XCTAssertEqual($0, "action")
        }
    }
}
