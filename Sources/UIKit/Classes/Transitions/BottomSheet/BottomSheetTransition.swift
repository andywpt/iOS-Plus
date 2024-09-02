import UIKit
/*
  UIViewControllerTransitioningDelegate's responsibility is to handle pairing for the correct presentation controller, animation controller and interaction controller for the presentation.
*/
class BottomSheetTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    private let configuration: BottomSheetTransitionConfiguration
    private var animationController: BottomSheetAnimationController!
    
    init(configuration: BottomSheetTransitionConfiguration) {
        self.configuration = configuration
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        animationController = nil
        return BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            configuration: configuration
        )
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if animationController == nil {
            animationController = BottomSheetAnimationController(
                presentedViewController: presented,
                configuration: configuration
            )
        }
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
    
    func interactionControllerForPresentation(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return animationController.isInteracting ? animationController : nil
    }
}
