import XCTest
@testable import EquatableByReflection

class EquatableByReflectionTests: XCTestCase {
    
    var nsO: NSObject { NSObject() }
    
    func assertEqual(_ lhs: Any, _ rhs: Any) {
        assert(XCTAssertTrue, lhs, rhs)
    }
    
    func assertNotEqual(_ lhs: Any, _ rhs: Any) {
        assert(XCTAssertFalse, lhs, rhs)
    }
    
    func assert(_ assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), _ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
        let errorMessage =
        """
        \nLHS: \(String(describing: lhs))
        \nRHS: \(String(describing: rhs))
        """
        assertion(haveSameValue(lhs, rhs), errorMessage, file, line)
    }
}

class SimpleFoundationTests: EquatableByReflectionTests {
    
    func testCG() {
        let a = CGFloat(0.1)
        let b = CGFloat(0.1)
        let c = CGFloat(0.2)
        
        assertEqual(a, b)
        assertNotEqual(a, c)
    }
    
    func testEqualArrays() {
        assertEqual([], [])
        assertEqual([1], [1])
        assertEqual([1, 2], [1, 2])
        assertEqual([[1, 2], [1, 2]], [[1, 2], [1, 2]])
    }
    
    func testNonEqualArrays() {
        assertNotEqual([], [1])
        assertNotEqual([1], [2])
        assertNotEqual([1, 2], [1, 3])
        assertNotEqual([[1, 2], [1, 2]], [[1, 2], [1, 3]])
    }
    
    func testEqualDictionaries() {
        assertEqual([:], [:])
        assertEqual(["1": 1], ["1": 1])
        assertEqual(["1": ["1": 1]], ["1": ["1": 1]])
    }
    
    func testNonEqualDictionaries() {
        assertNotEqual([:], ["1": 1])
        assertNotEqual(["1": 1], ["1": 2])
        assertNotEqual(["1": 1], ["2": 1])
    }

    var none            :  Any { Optional<Int>.none     as Any }
    func some(_ i: Int) -> Any { Optional<Int>.some(i)  as Any }
    
    func testEqualOptionals() {
        assertEqual(none, none)
        assertEqual(some(1), some(1))
    }
    
    func testNonEqualOptionals() {
        assertNotEqual(some(1), none)
        assertNotEqual(some(1), some(2))
    }
    
    func testTuples() {
        assertEqual((1, 1), (1, 1))
        assertNotEqual((1, 2), (1, 1))
    }
}

class ComplexFoundationTests: EquatableByReflectionTests {
    
    func testArrayOfNSObject() {
        assertEqual([nsO], [nsO])
        assertEqual([[nsO]], [[nsO]])
        
        assertNotEqual([[nsO]], [[nsO, nsO]])
    }
    
    func testDictionaryOfNSObject() {
        assertEqual([nsO: 1], [nsO: 1])
        assertEqual([nsO: nsO], [nsO: nsO])
        
        assertNotEqual([nsO: [nsO]], [nsO: [nsO, nsO]])
        assertNotEqual([nsO: 1], [nsO: 2])
    }
    
    func testPolymorphicCollections() {
        class A: NSObject {}
        class B: NSObject {}
        
        assertEqual([A()], [A()])
        assertNotEqual([A()], [B()])
        
        assertEqual([A(): B()], [A(): B()])
        assertEqual([B(): A()], [B(): A()])
        
        assertNotEqual([B(): A()], [B(): B()])
        assertNotEqual([A(): A()], [B(): A()])
    }
    
    func testNSArrays() {
        let a = [1, 2, 3, 4, 5].ns
        let b = NSArray(array: a)
        let c = a + [6]
        
        let aa = [a, a, a, a, a].ns
        let bb = NSArray(array: aa)
        let cc = aa.adding(aa)
        
        assertEqual(NSArray(), NSArray())
        assertEqual(a, b)
        assertEqual(aa, bb)
        
        assertNotEqual(a, c)
        assertNotEqual(aa, cc)
        assertNotEqual([1], [1].ns)
    }
    
    func testNSDictionaries() {
        let a = ["1": 1].ns
        let b = NSDictionary(dictionary: a)
        let c = ["2": 1].ns
        
        assertEqual(NSDictionary(), NSDictionary())
        assertEqual(a, b)
        
        assertNotEqual(a, c)
    }
    
    func testNSStrings() {
        let a = "a".ns
        let b = a
        let c = "c".ns
        
        assertEqual(a, b)
        assertNotEqual(a, c)
    }
    
    func testNSArraysOfNSStrings() {
        let s1 = "a".ns
        let s2 = "a".ns
        let s3 = "b".ns
        let a1 = [s1, s3].ns
        let a2 = [s3, s1].ns
        let a3 = [s3, s2].ns
        
        assertEqual(a1, a1)
        assertEqual(a2, a3)
        
        assertNotEqual(a1, a2)
    }
    
    func testComplexTuples() {
        let t1 = (nsO, "a".ns)
        let t2 = (nsO, "a".ns)
        let t3 = (nsO, "b".ns)
            
        assertEqual(t1, t2)
        assertNotEqual(t1, t3)
    }
    
    func testNestedTuples() {
        let t1 = (1, (1, 2))
        let t2 = (1, (1, 2))
        let t3 = (1, (1, 3))
        
        assertEqual(t1, t2)
        assertNotEqual(t1, t3)
    }
}

class SimpleCompositionTests: EquatableByReflectionTests {
    
    func testDifferentTypesNotEqual() {
        struct First {}
        struct Second {}
        
        assertNotEqual(First(), Second())
    }
    
    func testEmptyStructsEqual() {
        struct Null {}
        
        assertEqual(Null(), Null())
    }
    
    func testEmptyClassesEqual() {
        class Null {}
        
        assertEqual(Null(), Null())
    }
    
    func testStructsWithSingleValue() {
        struct OneField { let field: Int }
        
        assertNotEqual(OneField(field: 1), OneField(field: 2))
        assertEqual(OneField(field: 1), OneField(field: 1))
    }
    
    func testClassesWithSingleDifferentValue() {
        class OneField {
            let field: Int
            init(_ field: Int) { self.field = field }
        }
        
        assertNotEqual(OneField(1), OneField(2))
        assertEqual(OneField(1), OneField(1))
    }
    
    func testEnumCases() {
        enum Two { case first, second }
        
        assertNotEqual(Two.first, Two.second)
        assertEqual(Two.first, Two.first)
    }
    
    func testEnumAssociatedValues() {
        enum OneValue { case first(Int) }
        
        assertEqual(OneValue.first(1), OneValue.first(1))
        assertNotEqual(OneValue.first(1), OneValue.first(2))
    }
}

class ComplexCompositionTests: EquatableByReflectionTests {
    
    func testStructWithNSObjectEqualByPropertyValue() {
        struct NSHolder {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testClassWithNSObjectEqualByPropertyValue() {
        class NSHolder {
            let o = NSObject()
        }
        
        assertEqual(NSHolder(), NSHolder())
    }
    
    func testStructWithNSObjectAndInt() {
        struct NSHolder {
            let o = NSObject()
            let i: Int
        }
        
        assertEqual(NSHolder(i: 1), NSHolder(i: 1))
        assertNotEqual(NSHolder(i: 1), NSHolder(i: 2))
    }
    
    func testClassWithNSObjectAndInt() {
        class NSHolder {
            let o = NSObject()
            let i: Int
            
            init(i: Int) { self.i = i }
        }
        
        assertEqual(NSHolder(i: 1), NSHolder(i: 1))
        assertNotEqual(NSHolder(i: 1), NSHolder(i: 2))
    }

    struct Nested {
        let i: Int
        let o = NSObject()
    }
    
    func testStructWithNestedStruct() {
        struct NSHolder {
            let o = NSObject()
            let i: Int
            let n: Nested
            
            init(i: Int, n: Nested) {
                self.i = i
                self.n = n
            }
        }
        
        let h1 = NSHolder(i: 1, n: Nested(i: 1))
        let h2 = NSHolder(i: 1, n: Nested(i: 1))
        let h3 = NSHolder(i: 1, n: Nested(i: 2))
        
        assertEqual(h1, h2)
        assertNotEqual(h1, h3)
    }
    
    func testClassWithNestedStruct() {
        class NSHolder {
            let o = NSObject()
            let i: Int
            let n: Nested
            
            init(i: Int, n: Nested) {
                self.i = i
                self.n = n
            }
        }
        
        let h1 = NSHolder(i: 1, n: Nested(i: 1))
        let h2 = NSHolder(i: 1, n: Nested(i: 1))
        let h3 = NSHolder(i: 1, n: Nested(i: 2))
        
        assertEqual(h1, h2)
        assertNotEqual(h1, h3)
    }
    
    func testNestedNSString() {
        struct StringHolder {
            let s: NSString
        }
        
        assertEqual(StringHolder(s: "<".ns),
                    StringHolder(s: "<".ns))
        
        assertNotEqual(StringHolder(s: "<1".ns),
                       StringHolder(s: "<2".ns))
    }
    
    func testNestedArraysWithComplexObjects() throws {
        throw XCTSkip()
    }
    
    func testEnumWithAssociatedNSObject() {
        enum ObjectCase { case ns(NSObject) }
        
        assertEqual(ObjectCase.ns(nsO),
                    ObjectCase.ns(nsO))
    }
}

extension String {
    var ns: NSString {
        NSString(string: self)
    }
}

extension Array {
    var ns: NSArray {
        NSArray(array: self)
    }
}

extension Dictionary {
    var ns: NSDictionary {
        NSDictionary(dictionary: self)
    }
}
