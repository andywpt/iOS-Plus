import UIKit

extension UIView {
    func setRoundCorners(radius: CGFloat, curve: CALayerCornerCurve) {
        layer.cornerRadius = radius
        layer.cornerCurve = curve
        layer.masksToBounds = true
    }

    func setRoundCorners(radius: CGFloat, curve: CALayerCornerCurve, maskedCorners: CACornerMask) {
        setRoundCorners(radius: radius, curve: curve)
        layer.maskedCorners = maskedCorners
    }
}
