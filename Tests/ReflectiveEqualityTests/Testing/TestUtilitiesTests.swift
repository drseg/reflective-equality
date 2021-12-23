import XCTest
@testable import ReflectiveEquality

private func delay() {
    usleep(500)
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
        func action(completion: (String) -> ()) {
            neverComplete(completion: completion)
        }
        
        func action1(arg: Any, completion: (String) -> ()) {
            neverComplete(completion: completion)
        }
        
        func action2(arg1: Any, arg2: Any, completion: (String) -> ()) {
            neverComplete(completion: completion)
        }
        
        func fail() {
            XCTFail("Should not have reached this line")

        }
        
        expectDeferredFailure(count: 3) {
            performDeferred(action: action) { _ in
                fail()
            }
            
            performDeferred(action: action1, arg: "") { _ in
                fail()
            }
            
            performDeferred(action: action2, arg1: "", arg2: "") { _ in
                fail()
            }
        }
    }
    
    func testPerformDeferredWithActionFailsIfExpectationTimesOut() {
        func action(completion: @escaping (String) -> ()
        ) {
            completeDelayed(completion: completion)
        }
        
        func action1(arg: Any,
                     completion: @escaping (String) -> ()
        ) {
            completeDelayed(completion: completion)
        }
        
        func action2(arg1: Any,
                     arg2: Any,
                     completion: @escaping (String) -> ()
        ) {
            completeDelayed(completion: completion)
        }
               
        expectDeferredFailure(count: 3) {
            performDeferred(timeout: 0, action: action) {
                XCTAssertEqual($0, "action")
            }
            
            performDeferred(timeout: 0, action: action1, arg: "") {
                XCTAssertEqual($0, "action")
            }
            
            performDeferred(timeout: 0, action: action2, arg1: "", arg2: "") {
                XCTAssertEqual($0, "action")
            }
        }
    }
    
    func testPerformDeferredWithActionPassesIfFunctionCompletes() {
        func action(completion: (String) -> ()) {
            completeOnTime(completion: completion)
        }
        
        func action1(arg: Any, completion: (String) -> ()) {
            completeOnTime(completion: completion)
        }
        
        func action2(arg1: Any, arg2: Any, completion: (String) -> ()) {
            completeOnTime(completion: completion)
        }
        
        performDeferred(timeout: 0, action: action) {
            XCTAssertEqual($0, "action")
        }
        
        performDeferred(timeout: 0, action: action1, arg: "") {
            XCTAssertEqual($0, "action")
        }
        
        performDeferred(timeout: 0, action: action2, arg1: "", arg2: "") {
            XCTAssertEqual($0, "action")
        }
    }
}
