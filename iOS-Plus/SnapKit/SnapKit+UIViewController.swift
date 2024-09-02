#if canImport(SnapKit) && canImport(UIKit)
import SnapKit
import UIKit

extension UIViewController {
    
    func embed(_ childVC: UIViewController, in containerView: UIView, constraints: ((ConstraintMaker) -> Void)?) {
        addChild(childVC)
        if let constraints {
            containerView.addSubview(childVC.view, constraints: constraints)
        }
        childVC.didMove(toParent: self)
    }
}
#endif
