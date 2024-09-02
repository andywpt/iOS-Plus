import UIKit

final class BottomSheetAnimationController: UIPercentDrivenInteractiveTransition {
   
    private(set) var isInteracting = false
    private weak var presentedViewController: UIViewController!
    private var presentationAnimator: UIViewPropertyAnimator?
    private var dismissalAnimator: UIViewPropertyAnimator?
    private let configuration: BottomSheetTransitionConfiguration
    
    init(presentedViewController: UIViewController, configuration: BottomSheetTransitionConfiguration) {
        self.configuration = configuration
        self.presentedViewController = presentedViewController
        super.init()
        if configuration.dragToDismissEnabled {
            addPanGesture()
        }
    }
    
    private func addPanGesture(){
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(pannedPresentedView))
        panGesture.delegate = self
        presentedViewController?.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func pannedPresentedView(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isInteracting = true
            presentedViewController.presentingViewController!.dismiss(animated: true)
        case .changed:
            let view = recognizer.view!
            let dragAmount = max(recognizer.translation(in: view).y, 0)
            let adjustedHeight = view.frame.height - dragAmount
            let progress = 1 - (adjustedHeight / view.frame.height)
            update(progress)
        case .ended, .cancelled:
            let view = recognizer.view!
            let dragSpeed = recognizer.velocity(in: view).y
            let dismissFractionComplete = dismissalAnimator?.fractionComplete ?? .zero
            if dismissFractionComplete > 0.5 || dragSpeed > 450 {
                finish()
            } else {
                cancel()
            }
            self.isInteracting = false
        default:
            break
        }
    }
}

extension BottomSheetAnimationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panGesture = gestureRecognizer as! UIPanGestureRecognizer
        let translationY = panGesture.translation(in: panGesture.view!).y
        return translationY > 0
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = otherGestureRecognizer.view as? UIScrollView,
             otherGestureRecognizer == scrollView.panGestureRecognizer else {
            return false
        }
        return scrollView.contentOffset.y <= scrollView.contentOffsetMinY
    }
}

extension BottomSheetAnimationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
   
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: context).startAnimation()
    }
  
    func interruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if context.isPresenting {
            return presentationAnimator ?? createPresentationAnimator(using: context)
        } else {
            return dismissalAnimator ?? createDismissAnimator(using: context)
        }
    }
    
    private func createPresentationAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let toVC = context.viewController(forKey: .to)!
        let toView = context.view(forKey: .to)!
        let toViewEndFrame = context.finalFrame(for: toVC)
        
        toView.frame = toViewEndFrame.with {
            $0.origin.y = context.containerView.frame.maxY
        }
        
        context.containerView.addSubview(toView)
    
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: context),
            dampingRatio: 0.92
        )
        animator.addAnimations {
            toView.frame = toViewEndFrame
        }
        animator.addCompletion { [weak self] position in
            self?.presentationAnimator = nil
            guard case .end = position else {
                context.completeTransition(false)
                return
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
        presentationAnimator = animator
        return animator
    }
    
    private func createDismissAnimator(
        using context: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        let fromView = context.view(forKey: .from)!
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: context),
            dampingRatio: 0.92
        )
        animator.addAnimations {
            fromView.frame.origin.y = fromView.frame.maxY
        }
        animator.addCompletion { [weak self] position in
            guard let self else { return }
            dismissalAnimator = nil
            guard position == .end else {
                context.completeTransition(false)
                return
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
        dismissalAnimator = animator
        return animator
    }
}
