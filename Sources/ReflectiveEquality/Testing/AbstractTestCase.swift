import XCTest

public class AbstractTestCase: XCTestCase {
    
    public override class var defaultTestSuite: XCTestSuite {
        let defaultSuite = super.defaultTestSuite
        let tests = defaultSuite.tests
        
        let abstractTests = tests.filter { $0.name.contains("testAbstractly") }
        let concreteTests = tests.filter { !$0.name.contains("testAbstractly") }
        
        let newSuite = XCTestSuite(name: defaultSuite.name)
        let type = Self.self
        
        if type != AbstractTestCase.self && type != abstractBaseClass {
            abstractTests.forEach(newSuite.addTest)
        }
        concreteTests.forEach(newSuite.addTest)
        
        return newSuite
    }
    
    public class var abstractBaseClass: Any.Type {
        fatalError("Subclasses must implement")
    }
}

