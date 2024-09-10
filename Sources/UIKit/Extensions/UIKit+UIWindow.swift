import UIKit

extension UIWindow {
    
    static var keyWindow: UIWindow {
        return (UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow))!
    }
    // A view controller can only present one view controller at a time. If you send present(_:animated:completion:) to a view controller whose presentedViewController isn’t nil, nothing will happen and the completion function is not called (and you’ll get a warning from the runtime)
    //  A view controller whose presentingViewController is nil is not a presented view controller at this moment.
    var topLevelViewController: UIViewController {
        var topVC = rootViewController!
        while let currentTop = topVC.presentedViewController {
            topVC = currentTop
        }
        return topVC
    }

}
