import XCTest

open class AbstractTestCase: XCTestCase {
    open var abstractTestIdentifier: String {
        "testAbstractly"
    }

    open var abstractTestClass: XCTest.Type {
        fatalError("Subclasses must implement")
    }

    open override func perform(_ run: XCTestRun) {
        if shouldRun(run.test) {
            super.perform(run)
        }
    }
    
    private func shouldRun(_ test: XCTest) -> Bool {
        isConcreteSubclass || isConcrete(test)
    }
    
    private var isConcreteSubclass: Bool {
        Self.self != AbstractTestCase.self &&
        Self.self != abstractTestClass
    }
    
    private func isConcrete(_ test: XCTest) -> Bool {
        !test.name.contains(abstractTestIdentifier)
    }
}
