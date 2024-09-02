import UIKit

final class RetryIconView: View {
    //
//    isOpaque
//    This property is a horse of a different color; changing it has no effect on the view’s appearance. Rather, it is a hint to the drawing system. If a view is com‐ pletely filled with opaque material and its alpha is 1.0, so that the view has no effective transparency, then it can be drawn more efficiently (with less drag on performance) if you inform the drawing system of this fact by setting its isOpaque to true. Otherwise, you should set its isOpaque to false. The isOpaque value is not changed for you when you set a view’s backgroundColor or alpha! Setting it correctly is entirely up to you; the default, perhaps surprisingly, is true
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = nil
        isOpaque = false
        tintColor = .black
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = CGMutablePath().with {
            $0.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: min(rect.width, rect.height) * 0.5 * 0.7,
                startAngle: 2 * .pi * 0.95,
                endAngle: 2 * .pi * 0.75,
                clockwise: false
            )
        }
        let trianglePath = CGMutablePath().with {
            let a = (min(rect.width, rect.height) * 0.5) * 0.3 * 2
            $0.move(to: CGPoint(x: rect.midX, y: rect.minY))
            $0.addLine(to: CGPoint(
                x: rect.midX + (a * sqrt(2.0) * 0.5),
                y: rect.minY + (a * 0.5)
            ))
            $0.addLine(to: CGPoint(
                x: rect.midX,
                y: rect.minY + a
            ))
            $0.closeSubpath()
        }

        UIGraphicsGetCurrentContext()!.with {
            $0.setStrokeColor(tintColor.cgColor)
            $0.setFillColor(tintColor.cgColor)
            $0.setLineWidth(min(rect.width, rect.height) * 0.05)
            // Since the point around which the rotation takes place is the origin, we need to apply a translate transform first, to map the origin to the point around which you really want to rotate. But then, after rotating, in order to figure out where to draw, you will probably have to reverse your translate transform.
            $0.translateBy(x: rect.midX, y: rect.midY)
            $0.rotate(by: .pi / 4)
            $0.translateBy(x: -rect.midX, y: -rect.midY)
            
            $0.addPath(circlePath)
            $0.strokePath()
            $0.addPath(trianglePath)
            $0.fillPath()
        }
    }
}
