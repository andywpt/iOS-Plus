import UIKit

class MinimalBackButtonNavigationController: UINavigationController {
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach { $0.navigationItem.backButtonDisplayMode = .minimal }
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backButtonDisplayMode = .minimal
        super.pushViewController(viewController, animated: animated)
    }
}
