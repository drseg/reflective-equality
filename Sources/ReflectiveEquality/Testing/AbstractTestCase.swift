import XCTest


public class AbstractTestCase: XCTestCase {

    public var abstractTestPrefix: String {
        "testAbstractly"
    }

    public var abstractTestClass: XCTest.Type {
        fatalError("Subclasses must implement")
    }

    public override func perform(_ run: XCTestRun) {
        assert(
            abstractTestPrefix.prefix(4) == "test",
            "All test functions must begin with 'test'"
        )
        
        if isConcreteSubclass || testIsConcrete(run.test) {
            super.perform(run)
        }
    }
    
    private var isConcreteSubclass: Bool {
        Self.self != AbstractTestCase.self && Self.self != abstractTestClass
    }
    
    private func testIsConcrete(_ test: XCTest) -> Bool {
        !test.name.contains(abstractTestPrefix)
    }
}
