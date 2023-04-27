# Reflective Equality

![GitHub](https://img.shields.io/github/license/drseg/reflective-equality) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/drseg/reflective-equality/swift.yml?label=all%20tests)

Reflective Equality is a set of global functions that allows two Swift 'Any' instances to be compared by value. 

Values are compared by recursively traversing their properties and subproperties, as well as those of their parents (and parents' parents, etc.), combining the reflection affordances of `Swift.Mirror`, `Swift.String(describing:)`, and the Objective C runtime.

If all property values match, they are considered equal, even if the class instances are not identical (i.e., `!==`).

There is no way to prove such a function correct, and there are inevitably edge cases where a spurious result will be generated. The output is therefore only guaranteed to be correct against the specific test cases used.
