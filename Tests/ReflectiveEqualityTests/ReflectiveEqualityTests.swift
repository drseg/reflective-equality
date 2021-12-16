import XCTest
import Foundation
@testable import ReflectiveEquality

class ReflectiveEqualityTests: XCTestCase {
    var nsO: NSObject { NSObject() }
}

class SimpleFoundationTests: ReflectiveEqualityTests {
    
    func testCG() {
        let a = CGFloat(0.1)
        let b = CGFloat(0.1)
        let c = CGFloat(0.2)
        
        assertSameValue(a, b)
        assertNotSameValue(a, c)
    }
    
    func testEqualArrays() {
        assertSameValue([], [])
        assertSameValue([1], [1])
        assertSameValue([1, 2], [1, 2])
        assertSameValue([[1, 2], [1, 2]], [[1, 2], [1, 2]])
    }
    
    func testNonEqualArrays() {
        assertNotSameValue([], [1])
        assertNotSameValue([1], [2])
        assertNotSameValue([1, 2], [1, 3])
        assertNotSameValue([[1, 2], [1, 2]], [[1, 2], [1, 3]])
    }
    
    func testEqualDictionaries() {
        assertSameValue([:], [:])
        assertSameValue(["1": 1], ["1": 1])
        assertSameValue(["1": ["1": 1]], ["1": ["1": 1]])
    }
    
    func testNonEqualDictionaries() {
        assertNotSameValue([:], ["1": 1])
        assertNotSameValue(["1": 1], ["1": 2])
        assertNotSameValue(["1": 1], ["2": 1])
    }

    var none            :  Any { Optional<Int>.none     as Any }
    func some(_ i: Int) -> Any { Optional<Int>.some(i)  as Any }
    
    func testEqualOptionals() {
        assertSameValue(none, none)
        assertSameValue(some(1), some(1))
    }
    
    func testNonEqualOptionals() {
        assertNotSameValue(some(1), none)
        assertNotSameValue(some(1), some(2))
    }
    
    func testTuples() {
        assertSameValue((1, 1), (1, 1))
        assertNotSameValue((1, 2), (1, 1))
    }
    
    func testClosures() {
        let c1: () -> () = {            }
        let c2: () -> () = {            }
        let c3: () -> () = { print("c") }
        
        let c4: () -> (String)      = { "c" }
        let c5: (() -> (String))?   = { "c" }
        
        assertSameValue(c1, c2)
        assertSameValue(c1, c3)
        assertSameValue(c4, c5!) // c5 no longer wrapped
        
        assertNotSameValue(c1, c4)
        assertNotSameValue(c4, c5 as Any) // c5 remains wrapped
    }
    
    func testData() {
        let d1 = "Cat".data(using: .utf8)!
        let d2 = "Cat".data(using: .utf8)!
        let d3 = "Bat".data(using: .utf8)!
        
        assertSameValue(d1, d2)
        assertNotSameValue(d1, d3)
    }
}

class ComplexFoundationTests: ReflectiveEqualityTests {
    
    func testArrayOfNSObject() {
        assertSameValue([nsO], [nsO])
        assertSameValue([[nsO]], [[nsO]])
        
        assertNotSameValue([[nsO]], [[nsO, nsO]])
    }
    
    func testDictionaryOfNSObject() {
        assertSameValue([nsO: 1], [nsO: 1])
        assertSameValue([nsO: nsO], [nsO: nsO])
        
        assertNotSameValue([nsO: [nsO]], [nsO: [nsO, nsO]])
        assertNotSameValue([nsO: 1], [nsO: 2])
    }
    
    func testPolymorphicCollections() {
        class A: NSObject {}
        class B: NSObject {}
        
        assertSameValue([A()], [A()])
        assertNotSameValue([A()], [B()])
        
        assertSameValue([A(): B()], [A(): B()])
        assertSameValue([B(): A()], [B(): A()])
        
        assertNotSameValue([B(): A()], [B(): B()])
        assertNotSameValue([A(): A()], [B(): A()])
    }
    
    func testNSArrays() {
        let a = [1, 2, 3, 4, 5].ns
        let b = NSArray(array: a)
        let c = a + [6]
        
        let aa = [a, a, a, a, a].ns
        let bb = NSArray(array: aa)
        let cc = aa.adding(aa)
        
        assertSameValue(NSArray(), NSArray())
        assertSameValue(a, b)
        assertSameValue(aa, bb)
        
        assertNotSameValue(a, c)
        assertNotSameValue(aa, cc)
        assertNotSameValue([1], [1].ns)
    }
    
    func testNSDictionaries() {
        let a = ["1": 1].ns
        let b = NSDictionary(dictionary: a)
        let c = ["2": 1].ns
        
        assertSameValue(NSDictionary(), NSDictionary())
        assertSameValue(a, b)
        
        assertNotSameValue(a, c)
    }
    
    func testNSStrings() {
        let a = "a".ns
        let b = a
        let c = "c".ns
        
        assertSameValue(a, b)
        assertNotSameValue(a, c)
    }
    
    func testNSAttributedString() {
        let s1 = NSMutableAttributedString(string: "Cat")
        let s2 = NSMutableAttributedString(string: "Cat")
        
        let range1 = NSRange(location: 0, length: 1)
        let range2 = NSRange(location: 1, length: 1)
        
        s1.addAttribute(.font, value: NSFont(name: "Helvetica", size: 10)!, range: range2)
        s2.addAttribute(.font, value: NSFont(name: "Arial", size: 10)!, range: range2)
        
        assertNotSameValue(s1, s2)
        
        s1.addAttribute(.font, value: NSObject(), range: range1)
        s2.addAttribute(.font, value: NSObject(), range: range1)
        
        assertNotSameValue(s1, s2)
    }
    
    func testComplexNSAttributedString() {
        var parsingOptions: [NSAttributedString.DocumentReadingOptionKey : Any] {
            [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        }
        
        var parsedHTML: NSAttributedString {
            NSAttributedString(html: html.data(using: .utf8)!,
                               options: parsingOptions,
                               documentAttributes: nil)!
        }
        
        assertSameValue(parsedHTML, parsedHTML)
    }
    
    func testStringsNotAffectedByClassIDRemoval() {
        let s1 = "<NSObject: XXXXXX>"
        let s2 = "<NSObject: YYYYYY>"
        assertNotSameValue(s1, s2)
    }
    
    func testNSStringsNotAffectedByClassIDRemoval() {
        let s1 = "<NSObject: XXXXXX>".ns
        let s2 = "<NSObject: YYYYYY>".ns
        assertNotSameValue(s1, s2)
    }
    
    func testSubstringsNotAffectedByClassIDRemoval() {
        let s1 = Substring("<NSObject: XXXXXX>")
        let s2 = Substring("<NSObject: YYYYYY>")
        assertNotSameValue(s1, s2)
    }
    
    func testNSArraysOfNSStrings() {
        let s1 = "a".ns
        let s2 = "a".ns
        let s3 = "b".ns
        let a1 = [s1, s3].ns
        let a2 = [s3, s1].ns
        let a3 = [s3, s2].ns
        
        assertSameValue(a1, a1)
        assertSameValue(a2, a3)
        
        assertNotSameValue(a1, a2)
    }
    
    func testComplexTuples() {
        let t1 = (nsO, "a".ns)
        let t2 = (nsO, "a".ns)
        let t3 = (nsO, "b".ns)
            
        assertSameValue(t1, t2)
        assertNotSameValue(t1, t3)
    }
    
    func testNestedTuples() {
        let t1 = (1, (1, 2))
        let t2 = (1, (1, 2))
        let t3 = (1, (1, 3))
        
        assertSameValue(t1, t2)
        assertNotSameValue(t1, t3)
    }
}

class SimpleCompositionTests: ReflectiveEqualityTests {
    
    func testDifferentTypesNotEqual() {
        struct First {}
        struct Second {}
        
        assertNotSameValue(First(), Second())
    }
    
    func testEmptyStructsEqual() {
        struct Null {}
        
        assertSameValue(Null(), Null())
    }
    
    func testEmptyClassesEqual() {
        class Null {}
        
        assertSameValue(Null(), Null())
    }
    
    func testStructsWithSingleValue() {
        struct OneField { let field: Int }
        
        assertNotSameValue(OneField(field: 1), OneField(field: 2))
        assertSameValue(OneField(field: 1), OneField(field: 1))
    }
    
    func testClassesWithSingleDifferentValue() {
        class OneField {
            let field: Int
            init(_ field: Int) { self.field = field }
        }
        
        assertNotSameValue(OneField(1), OneField(2))
        assertSameValue(OneField(1), OneField(1))
    }
    
    func testEnumCases() {
        enum Two { case first, second }
        
        assertNotSameValue(Two.first, Two.second)
        assertSameValue(Two.first, Two.first)
    }
    
    func testEnumAssociatedValues() {
        enum OneValue { case first(Int) }
        
        assertSameValue(OneValue.first(1), OneValue.first(1))
        assertNotSameValue(OneValue.first(1), OneValue.first(2))
    }
}

class ComplexCompositionTests: ReflectiveEqualityTests {
    
    func testStructWithNSObjectEqualByPropertyValue() {
        struct NSHolder {
            let o = NSObject()
        }
        
        assertSameValue(NSHolder(), NSHolder())
    }
    
    func testClassWithNSObjectEqualByPropertyValue() {
        class NSHolder {
            let o = NSObject()
        }
        
        assertSameValue(NSHolder(), NSHolder())
    }
    
    func testStructWithNSObjectAndInt() {
        struct NSHolder {
            let o = NSObject()
            let i: Int
        }
        
        assertSameValue(NSHolder(i: 1), NSHolder(i: 1))
        assertNotSameValue(NSHolder(i: 1), NSHolder(i: 2))
    }
    
    func testClassWithNSObjectAndInt() {
        class NSHolder {
            let o = NSObject()
            let i: Int
            
            init(i: Int) { self.i = i }
        }
        
        assertSameValue(NSHolder(i: 1), NSHolder(i: 1))
        assertNotSameValue(NSHolder(i: 1), NSHolder(i: 2))
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
        
        assertSameValue(h1, h2)
        assertNotSameValue(h1, h3)
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
        
        assertSameValue(h1, h2)
        assertNotSameValue(h1, h3)
    }
    
    func testNestedNSString() {
        struct StringHolder {
            let s: NSString
        }
        
        assertSameValue(StringHolder(s: "<".ns),
                    StringHolder(s: "<".ns))
        
        assertNotSameValue(StringHolder(s: "<1".ns),
                       StringHolder(s: "<2".ns))
    }
    
    func testInheritance() throws {
        class Parent {
            let a: Int
            init(_ a: Int) { self.a = a }
        }
        
        class Child: Parent {}
        class GrandChild: Child {}
        class Cousin: Parent {
            let b: Int
            init(_ a: Int, _ b: Int) { self.b = b; super.init(a) }
        }
                
        assertSameValue(Child(1), Child(1))
        assertSameValue(GrandChild(1), GrandChild(1))
        assertSameValue(Cousin(1, 1), Cousin(1, 1))

        assertNotSameValue(Child(1), Child(2))
        assertNotSameValue(GrandChild(1), GrandChild(2))
        assertNotSameValue(Cousin(1, 1), Cousin(1, 2))
        assertNotSameValue(Cousin(1, 1), Cousin(2, 1))
    }
    
    func testObjectsWithClosureProperties() {
        class Closure {
            let s: String
            let c: () -> ()
            init(_ s: String, _ c: @escaping () -> ()) {
                self.s = s
                self.c = c
            }
        }
        
        let c1 = Closure("a") { print("c1") }
        let c2 = Closure("a") {             }
        let c3 = Closure("b") {             }
        
        assertSameValue(c1, c2)
        assertNotSameValue(c1, c3)
    }
    
    func testEnumWithAssociatedNSObject() {
        enum ObjectCase { case ns(NSObject) }
        
        assertSameValue(ObjectCase.ns(nsO),
                        ObjectCase.ns(nsO))
    }
}

class MultiArgTests: ReflectiveEqualityTests {
       
    func testMultipleArguments() {
        assertSameValue([])
        assertSameValue([1])
        assertSameValue([1, 1, 1, 1])
        assertSameValue([nsO, nsO, nsO, nsO])
        
        assertNotSameValue([1, 1, 1, 2])
        assertNotSameValue([1, 1, nsO])
    }
}

class ErrorHandlingTests: XCTestCase {
    
    func testEqualErrorConditions() {
        let error = generateEqualErrorMessage
        
        XCTAssertEqual(error([]), "")
        XCTAssertEqual(error([1]), "1 must equal itself")
        XCTAssertEqual(error([1, 1]), "\nActual: 1\nExpected: 1")
        XCTAssertEqual(error([1, 1, 1]), "\nArg 1: 1\nArg 2: 1\nArg 3: 1")
        XCTAssertEqual(error([1, 1, 1, 1]), "\nArg 1: 1\nArg 2: 1\nArg 3: 1\nArg 4: 1")
    }
    
    func testNonEqualErrorConditions() {
        let prefix = "All arguments were unexpectedly equal to "
        let error = generateNonEqualErrorMessage
        
        XCTAssertEqual(error([]), prefix + "empty")
        XCTAssertEqual(error([1]), prefix + "1")
        XCTAssertEqual(error([1, 1]), prefix + "1")
        XCTAssertEqual(error([1, 1, 1]), prefix + "1")
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
