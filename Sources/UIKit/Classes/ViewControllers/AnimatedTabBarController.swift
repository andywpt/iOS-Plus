import UIKit

class AnimatedTabBarController: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

extension AnimatedTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_: UITabBarController, animationControllerForTransitionFrom _: UIViewController, to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HorizontalSlideTransitionAnimationController()
    }
    
}
