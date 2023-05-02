# Reflective Equality

![Platform Compatability][image-1]![Swift Compatability][image-2][![codecov][image-3]][1] ![Testspace tests][image-4] ![GitHub Workflow Status][image-5] ![GitHub][image-6] 

Reflective Equality is a set of global functions that allows two Swift 'Any' instances to be compared by value. 

Values are compared by recursively traversing their properties and subproperties, as well as those of their parents (and parents' parents, etc.), combining the reflection affordances of `Swift.Mirror`, `Swift.String(describing:)`, and the Objective C runtime. If all property values match, they are considered equal, even if the class instances are not identical (i.e., `!==`).

## Guidance

There is no way to prove that this works on a general basis, and there are inevitably edge cases where a spurious result will be generated. The output is therefore only guaranteed to be correct against the kinds of test cases used to drive the package’s development.

If you’re not sure if you need this, you almost certainly don’t! It is best used for very particular cases when you can be sure it will do the job for you, and that the job is one that actually should be done in the first place. Though it is still under active development (and suggestions are welcome), consider it more of a curiosity than anything else!

## Usage

The framework offers three main public functions:

```swift
public func haveSameValue(_ args: [Any]) -> Bool
public func haveSameValue(_ lhs: Any, _ rhs: Any) -> Bool

public func deepDescription(_ instance: Any) -> String
```

These can be used as follows:

```swift
import ReflectiveEquality

class MyClass {
    func myMethod() {
        _ = haveSameValue("cat", "cat") // true
        _ = haveSameValue(["cat", "cat", "cat", "cat"] // true

        _ = haveSameValue("cat", "bat") // false
    }
}
```

Clearly the above examples are equatable, so the use of `String` instances is purely for example’s sake - clearly an extra package isn’t needed to do this.

Slightly more interestingly, a comparison of `Equatable` conforming types that can’t be made reliably with `==`:

```swift
import ReflectiveEquality
import XCTest

class MyClass: XCTestCase {
    func testComplexNSAttributedString() {
        typealias ReadingOption = NSAttributedString.DocumentReadingOptionKey
        typealias DocumentType = NSAttributedString.DocumentType
        
        var parsingOptions: [ReadingOption: Any] {
            [ReadingOption.documentType: DocumentType.html]
        }

        var parsedHTML: NSAttributedString {
            NSAttributedString(html: giantHTML.data(using: .utf8)!,
                               options: parsingOptions,
                               documentAttributes: nil)!
        }

        XCTAssertEqual(deepDescription(parsedHTML), deepDescription(parsedHTML)) // ✅
        XCTAssertEqual(parsedHTML, parsedHTML) // ❌
    }
}
```

This case applies to various NS… classes. Maybe you’d like to see if two `NSFont` instances are the same font? Or stuff like that.

Here’s an unusual use case for `deepDescription`:

```swift
import ReflectiveEquality

class MyClass: NSObject {
    func myMethod() {
        _ = "cat" is NSObject // true!
        _ = isNSObject("cat") // false!
        _ = isNSObject(self)  // true!
    }

    func isNSObject(_ instance: Any) -> Bool {
        deepDescription(instance).contains("NSObject")
    }
}
```

Swift has a lovely way of telling you that all kinds of things are an `NSObject`. Which they sort of are. And aren’t. And maybe. But really, if I ask it if `struct Swift.String { }` is an `NSObject`, in a pure Swift context I’d prefer it just said no. Which ReflectiveEquality does.

Reflective Equality also has a completely experimental set of functions for probing ObjC properties and ivars:

```swift
extension NSObject {    
    public var propertiesAndIvars: [String: Any]
    public var ivars: [String: Any]
    public var properties: [String: Any]

    public var propertyAndIvarValues: [Any]
    public var propertyValues: [Any]
    public var ivarValues: [Any]
}
```

`properties` are fine, but `ivars` have a habit of crashing horribly with `EXC_BAD_ACCESS` when you try to probe them from Swift. So, have fun blowing things up!

[1]:	https://codecov.io/gh/drseg/reflective-equality

[image-1]:	https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdrseg%2Freflective-equality%2Fbadge%3Ftype%3Dplatforms
[image-2]:	https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdrseg%2Freflective-equality%2Fbadge%3Ftype%3Dswift-versions
[image-3]:	https://codecov.io/gh/drseg/reflective-equality/branch/master/graph/badge.svg?token=FAYRLLCT5P
[image-4]:	https://img.shields.io/testspace/tests/drseg/drseg:reflective-equality/master
[image-5]:	https://img.shields.io/github/actions/workflow/status/drseg/reflective-equality/swift.yml
[image-6]:	https://img.shields.io/github/license/drseg/reflective-equality