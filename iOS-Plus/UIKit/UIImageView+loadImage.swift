#if canImport(SDWebImage)

import SDWebImage
import UIKit

protocol ImageSource {}

extension String: ImageSource {}
extension URL: ImageSource {}

extension UIImageView {
    
    func loadImage(from source: ImageSource?) {
        if let url = source as? URL {
            sd_cancelCurrentImageLoad()
            sd_setImage(with: url, placeholderImage: nil)
            return
//            self.sd_setImage(with: url, placeholderImage: nil , options: SDWebImageOptions.avoidAutoSetImage, completed: { (image, error, cacheType, url) in
//                if cacheType == SDImageCacheType.none {
//                    UIView.transition(with: self.superview!, duration: 0.2, options:  [.transitionCrossDissolve ,.allowUserInteraction, .curveEaseIn], animations: {
//                        self.image = image
//                    }, completion: { (completed) in
//                    })
//                } else {
//                    self.image = image
//                }
//            })
        } else if let name = source as? String {
            if let systemImage = UIImage(systemName: name) {
                image = systemImage
            } else if let customImage = UIImage(named: name) {
                //// auto start animation
                image = customImage

            } else {
                image = nil
                print("⚠️ Cannot load image with name '\(name)'")
            }
        } else {
            image = nil
        }
    }

    func setImageAnimated(imageUrl: URL, placeholderImage: UIImage) {
        sd_setImage(with: imageUrl, placeholderImage: placeholderImage, options: SDWebImageOptions.avoidAutoSetImage, completed: { image, _, cacheType, _ in
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: self.superview!, duration: 0.2, options: [.transitionCrossDissolve, .allowUserInteraction, .curveEaseIn], animations: {
                    self.image = image
                }, completion: { _ in
                })
            } else {
                self.image = image
            }
        })
    }
}
#endif
