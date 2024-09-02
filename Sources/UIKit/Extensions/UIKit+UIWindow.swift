import UIKit

extension UIWindow {
    
    static var keyWindow: UIWindow {
        return UIApplication.shared.windows.filter(\.isKeyWindow).first!
    }
    
    var topLevelViewController: UIViewController {
        var topVC = rootViewController!
        while let currentTop = topVC.presentedViewController {
            topVC = currentTop
        }
        return topVC
    }

}
