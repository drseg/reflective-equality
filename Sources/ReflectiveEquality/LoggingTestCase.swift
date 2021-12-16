import XCTest

public protocol Loggable {

   func isIdenticalToEntry(_ entry: Loggable) -> Bool
}

public protocol TestLogger {

   func log(_ observed: Loggable)
   func logSequence(_ sequence: [Loggable])
}

open class LoggingTestCase: XCTestCase, TestLogger {

   private var log: [Loggable]?

   public var readOnlyLog: [Loggable]? {
       return log
   }

   public func log(_ observed: Loggable) {
       if log == nil {
           log = [Loggable]()
       }
       log!.append(observed)
   }

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

   public func logSequence(_ sequence: [Loggable]) {
       for entry in sequence {
           log(entry)
       }
   }

   public func assertLoggedNothing(file: StaticString = #file, line: UInt = #line) {
       XCTAssertEqual(0, (log ?? []).count, file: file, line: line)
   }

   public func assertLoggedLastSequence(_ s: [Loggable], startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
       assertLoggedSequence(s, startingAt: start, file: file, line: line)
       assertLoggedLast(s.last!, atIndex: start + s.count - 1, file: file, line: line)
   }

   public func assertLoggedSequence(_ s: [Loggable], startingAt start: Int = 0, file: StaticString = #file, line: UInt = #line) {
       for (index, entry) in s.enumerated() {
           assertLogged(entry, atIndex: start + index, file: file, line: line)
       }
   }

   public func assertLoggedLast(_ expected: Loggable, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
       assertLogged(expected, atIndex: index, file: file, line: line)
       assertLogLength(index + 1)
   }

   public func assertLogged(_ expected: Loggable, atIndex index: Int = 0, file: StaticString = #file, line: UInt = #line) {
       guard let ll = log, index < ll.count else {
           XCTFail("Expected an item number \(index + 1), but observed only \(log?.count ?? 0) item(s).", file: file, line: line)
           return
       }
       let observed = ll[Int(index)]
       XCTAssert(expected.isIdenticalToEntry(observed), "Expected \(expected), but observed \(observed)", file: file, line: line)
   }

   public func assertLogLength(_ expected: Int, file: StaticString = #file, line: UInt = #line) {
       XCTAssertEqual(log?.count ?? 0, expected, file: file, line: line)
   }

   public func printLog() {
       print("\n**Start Log**\n")
       for (i, l) in log!.enumerated() { print("\(i), \(l)") }
       print("\n**End Log**\n")
   }
}

extension String: Loggable {

   public func isIdenticalToEntry(_ entry: Loggable) -> Bool {
       guard let e = entry as? String else {
           return false
       }
       return e == self
   }
}

extension NSAttributedString: Loggable {

   public func isIdenticalToEntry(_ entry: Loggable) -> Bool {
       guard let e = entry as? NSAttributedString else {
           return false
       }
       return e.isEqual(self)
   }
}

public extension String {

   var scrambled: String {
       String(self.shuffled())
   }
}
