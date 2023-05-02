# Reflective Equality

[![codecov][image-1]][1] ![Testspace tests][image-2] ![GitHub Workflow Status][image-3] ![GitHub][image-4] 

Reflective Equality is a set of global functions that allows two Swift 'Any' instances to be compared by value. 

Values are compared by recursively traversing their properties and subproperties, as well as those of their parents (and parents' parents, etc.), combining the reflection affordances of `Swift.Mirror`, `Swift.String(describing:)`, and the Objective C runtime.

If all property values match, they are considered equal, even if the class instances are not identical (i.e., `!==`).

There is no way to prove such a function correct, and there are inevitably edge cases where a spurious result will be generated. The output is therefore only guaranteed to be correct against the specific test cases used.

## Guidance

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

Swift has a lovely way of telling you that all kinds of things are an `NSObject`. Which they sort of are. And aren’t. And maybe. But really, if I ask it if `struct Swift.String { }` is an `NSObject`, I’d prefer it just said no. Which ReflectiveEquality does.

[1]:	https://codecov.io/gh/drseg/reflective-equality

[image-1]:	https://codecov.io/gh/drseg/reflective-equality/branch/master/graph/badge.svg?token=FAYRLLCT5P
[image-2]:	https://img.shields.io/testspace/tests/drseg/drseg:reflective-equality/master
[image-3]:	https://img.shields.io/github/actions/workflow/status/drseg/reflective-equality/swift.yml
[image-4]:	https://img.shields.io/github/license/drseg/reflective-equality