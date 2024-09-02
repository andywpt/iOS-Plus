import UIKit

extension UIViewControllerContextTransitioning {
    
    var isPresenting: Bool {
        let toVC = viewController(forKey: .to)!
        let fromVC = viewController(forKey: .from)!
        return toVC.presentingViewController == fromVC
    }
}
