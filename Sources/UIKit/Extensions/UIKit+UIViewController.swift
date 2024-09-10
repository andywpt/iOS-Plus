import UIKit

// https://nshipster.com/swift-objc-runtime/
// https://blog.ficowshen.com/page/post/61
// https://github.com/atrick/swift-evolution/blob/diagnose-implicit-raw-bitwise/proposals/nnnn-implicit-raw-bitwise-conversion.md#workarounds-for-common-cases
// https://forums.swift.org/t/handling-the-new-forming-unsaferawpointer-warning/65523/7

extension UIViewController {
    
    private enum AssociatedKeys {
        static let transition = malloc(1)!
    }

    var transition: (any UIViewControllerTransitioningDelegate)? {
        get {
            objc_getAssociatedObject(self, AssociatedKeys.transition) as? (any UIViewControllerTransitioningDelegate)
        }
        set {
            if newValue != nil { modalPresentationStyle = .custom }
            transitioningDelegate = newValue
            objc_setAssociatedObject(self, AssociatedKeys.transition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isBeingPresented: Bool {
        return presentingViewController != nil
    }
    
    var canPresentViewController: Bool {
        return presentedViewController == nil
    }
}
