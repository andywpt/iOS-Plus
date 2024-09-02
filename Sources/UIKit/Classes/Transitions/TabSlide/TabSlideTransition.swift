import UIKit

final class HorizontalSlideTransitionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
   
    var completion: (() -> ())?
    private var animator: UIViewImplicitlyAnimating?
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: context).startAnimation()
    }
    
    func interruptibleAnimator(using context: UIViewControllerContextTransitioning) ->  UIViewImplicitlyAnimating {
        if animator == nil { animator = makeAnimator(using: context) }
        return animator!
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("transitionCompleted \(transitionCompleted)")
    }
    
    private func makeAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        print("making new animator")
        let fromVC = context.viewController(forKey: .from)!
        let fromVCIndex = fromVC.tabBarController!.viewControllers!.firstIndex(of: fromVC)!
        let fromView = context.view(forKey: .from)!
        let fromViewStartFrame = context.initialFrame(for: fromVC)
        
        let toVC = context.viewController(forKey: .to)!
        let toVCIndex = toVC.tabBarController!.viewControllers!.firstIndex(of: toVC)!
        let toView = context.view(forKey: .to)!
        let toViewEndFrame = context.finalFrame(for: toVC)
        
        let slideDirection: CGFloat = toVCIndex > fromVCIndex ? 1 : -1
        
        var fromViewEndFrame = fromViewStartFrame
        fromViewEndFrame.origin.x -= fromViewEndFrame.width * slideDirection
        
        var toViewStartFrame = toViewEndFrame
        toViewStartFrame.origin.x += toViewStartFrame.width * slideDirection
        
        toView.frame = toViewStartFrame
            
        context.containerView.addSubview(toView)
        
        let duration = transitionDuration(using: context)
        
        return UIViewPropertyAnimator(duration: duration, curve: .easeInOut).with {
            $0.addAnimations {
                fromView.frame = fromViewEndFrame
                toView.frame = toViewEndFrame
            }
            $0.addCompletion { _ in 
                context.completeTransition(true)
                self.completion?()
            }
        }
    }
}
