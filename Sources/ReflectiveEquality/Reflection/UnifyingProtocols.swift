import Foundation

/// Conform types that should not be probed by ObjCReflection if used in conjunction with Swift.Mirror
protocol SwiftMirrorUnsafe {}

extension NSString: SwiftMirrorUnsafe {}
extension NSNumber: SwiftMirrorUnsafe {}

/// Conform types that should not have hex numbers removed from their descriptions
protocol HexNumbersAllowed {}

extension String: HexNumbersAllowed {}
extension Substring: HexNumbersAllowed {}
extension NSString: HexNumbersAllowed {}
