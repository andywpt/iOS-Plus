import UIKit

extension CGSize {
    /// Scales up a point-size CGSize into its pixel representation.
    var pixelSize: CGSize {
        let scale = UIScreen.shared.scale
        return CGSize(width: width * scale, height: height * scale)
    }
}
