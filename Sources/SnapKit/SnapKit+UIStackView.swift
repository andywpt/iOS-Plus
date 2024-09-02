#if canImport(SnapKit) && canImport(UIKit)
import SnapKit
import UIKit

extension UIStackView {
    func addArrangedSubview(_ view: UIView, constraints: (ConstraintMaker) -> Void) {
        addArrangedSubview(view)
        view.snp.makeConstraints(constraints)
    }
}
#endif
