import XCTest
import ExceptionCatcher
@testable import ReflectiveEquality

final class ObjCReflectionTests: XCTestCase {
    
#warning("Probing ivars often leads to EXC_BAD_ACCESS. It is here for completeness but in general only properties should be used")
    
    let s = NSMutableAttributedString(string: "cat", attributes: [.font: NSFont(name: "Arial", size: 10)!])
    
    func testProperties() {
        XCTAssertEqual(s.properties["string"] as? String, "cat")
        XCTAssertFalse(s.properties.description.contains("Arial"))
    }
    
    func testIvars() {
        let sut = s.ivars
        XCTAssertEqual(sut["mutableString"] as? String, "cat")
        XCTAssertTrue(sut.description.contains("Arial"))
    }
    
    func testPropertiesAndIvars() {
        let sut = s.propertiesAndIvars
        XCTAssertGreaterThan(sut.count, s.properties.count)
        XCTAssertGreaterThan(sut.count, s.ivars.count)
        
        XCTAssertEqual(sut["string"] as? String, "cat")
        XCTAssert(sut.description.contains("Arial"))
    }
    
    func testPropertyValues() {
        XCTAssert(s.propertyValues.contains { $0 as? String == "cat" })
        XCTAssertFalse(s.propertyValues.description.contains("Arial"))
    }
    
    func testIvarValues() {
        XCTAssert(s.ivarValues.contains { $0 as? String == "cat" })
        XCTAssertTrue(s.ivarValues.description.contains("Arial"))
    }
    
    func testPropertyAndIvarValues() {
        let sut = s.propertyAndIvarValues
        XCTAssertGreaterThan(sut.count, s.properties.count)
        XCTAssertGreaterThan(sut.count, s.ivars.count)
        
        XCTAssert(sut.contains { $0 as? String == "cat" })
        XCTAssert(sut.description.contains("Arial"))
    }
    
    func testPropertyAndIvarValuesDoNotContainOptionals() {
        XCTAssert(!s.propertyAndIvarValues.contains { $0 as Optional<Any> == nil })
    }
    
    func testPropertyAndIvarValuesForNSObjectBaseAreEmpty() {
        XCTAssert(NSObject().propertyAndIvarValues.isEmpty)
        XCTAssert(NSObject().propertiesAndIvars.isEmpty)
    }
    
    func testPropertyandIvarKeysDoNotContainDescriptions() throws {
        let sut = s.propertiesAndIvars
        XCTAssertFalse(sut.contains { $0.key == "description" })
        XCTAssertFalse(sut.contains { $0.key == "debugDescription" })
    }
    
    func testSwiftTypesInvisibleToObjC() {
        class A: NSObject {
            enum Invisible { case invisible }
            let invisible = Invisible.invisible
        }

        XCTAssertFalse(A().propertyKeys.contains("invisible"))
    }
}

final class SwiftMirrorCompatabilityTests: XCTestCase {
    
#warning("These tests ensure that the implementation does not cause EXC_BAD_ACCESS when instances retrieved via Swift.Mirror.children are interrogated with these methods. NSNumber and NSString appear to be a culprits, but there may be others")
    
    func assertMirrorSafe(_ actual: NSObject, expected: String) {
        let properties = actual.properties
        XCTAssert(properties.values.allSatisfy { $0 is String })
        XCTAssertEqual(properties.count, 1)
        XCTAssertEqual(properties[""] as! String, expected)
    }
    
    func assertMirrorCompatible(_ instance: Any) {
        let mirror = Mirror(reflecting: instance)
        for child in mirror.children {
            let child = child.value as? NSObject
            XCTAssertNotNil(child?.properties)
        }
    }
    
    func testNSNumberPropertiesReturnSimpleDescription() {
        assertMirrorSafe(NSNumber(integerLiteral: 1), expected: "1")
    }
    
    func testCompatabilityWithNSNumber() throws {
        assertMirrorCompatible(NSArray(array: [1, 2, 3, 4, 5]))
    }
    
    func testNSStringPropertiesReturnSimpleDescription() {
        assertMirrorSafe(NSString(string: "a"), expected: "a")
    }
    
    func testCompatabilityWithNSString() throws {
        assertMirrorCompatible(NSArray(array: ["1", "2", "3", "4", "5"]))
    }
}
