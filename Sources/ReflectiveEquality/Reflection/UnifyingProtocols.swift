import Foundation

/// Types that should not be probed by ObjCReflection if used in conjunction with Swift.Mirror
protocol SwiftMirrorUnsafe {}

extension NSString: SwiftMirrorUnsafe {}
extension NSNumber: SwiftMirrorUnsafe {}

/// Types that should not have hex numbers removed from their descriptions
protocol Stringy {}

extension String: Stringy {}
extension Substring: Stringy {}
extension NSString: Stringy {}
