#if canImport(SnapKit) && canImport(UIKit)
import SnapKit
import UIKit

extension UIView {
    
    func addSubview(_ view: UIView, constraints: (ConstraintMaker) -> Void) {
        addSubview(view)
        view.snp.makeConstraints(constraints)
    }
    
    func insertSubview(_ view: UIView, at index: Int, constraints: (ConstraintMaker) -> Void){
        insertSubview(view, at: index)
        view.snp.makeConstraints(constraints)
    }
    
    @discardableResult
    func addConstraints(_ constraints: (ConstraintMaker) -> Void) -> Self {
        snp.makeConstraints(constraints)
        return self
    }
}
#endif
