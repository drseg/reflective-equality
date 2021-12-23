import XCTest
@testable import ReflectiveEquality

private func delay() {
    usleep(550)
}

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
            delay()
            completion("action")
        }
    }
    
    func completeOnTime(completion: (String) -> ()) {
        completion("action")
    }
    
    func performAllDeferred(timeout: Double = 0.1, action: (@escaping (String) -> ()) -> (), completion: @escaping (String) -> ()) {
        performDeferred(timeout: timeout, action: { block in
            action { block($0) }
        }, completion: completion)
        
        performDeferred(timeout: timeout, action: { _, block in
            action { block($0) }
        }, arg: 0, completion: completion)

        performDeferred(timeout: timeout, action: { _,_, block in
            action { block($0) }
        }, arg1: 0, arg2: 0, completion: completion)

        performDeferred(timeout: timeout, action: { _,_,_, block in
            action { block($0) }
        }, arg1: 0, arg2: 0, arg3: 0, completion: completion)

        performDeferred(timeout: timeout, action: { _,_,_,_, block in
            action { block($0) }
        }, arg1: 0, arg2: 0, arg3: 0, arg4: 0, completion: completion)
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
                    delay()
                    e.fulfill()
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
