import CoreGraphics
// https://gist.github.com/nicklockwood/9b4aac87e7f88c80e932ba3c843252df
// https://blog.eppz.eu/declarative-uikit-with-10-lines-of-code
protocol WithCompatible {}

extension WithCompatible {
    @discardableResult
    func with(_ configuration: (inout Self) -> Void) -> Self {
        var copy = self
        configuration(&copy)
        return copy
    }
}

extension NSObject: WithCompatible {}
extension CGPath: WithCompatible {}
extension CGContext: WithCompatible {}
extension CGRect: WithCompatible {}
