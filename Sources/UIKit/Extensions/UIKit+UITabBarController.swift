import UIKit

extension UITabBarController {
    @discardableResult
    func withTabBarAppearance(_ appearence: UITabBarAppearance) -> Self{
        tabBar.standardAppearance = appearence
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearence
        }
        return self
    }
}
