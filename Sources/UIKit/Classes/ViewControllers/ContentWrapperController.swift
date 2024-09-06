import SnapKit
import UIKit

class ContentWrapperController: UIViewController {
    
    var viewController: UIViewController? { children.first }
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func setViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if let fromVC = children.first {
            addChild(viewController)
            fromVC.willMove(toParent: nil)
            transition(from: fromVC, to: viewController, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
                viewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            } completion: { _ in
                viewController.didMove(toParent: self)
                fromVC.removeFromParent()
                completion?()
            }
        } else {
            addChild(viewController)
            view.addSubview(viewController.view) { $0.edges.equalToSuperview() }
            viewController.didMove(toParent: self)
            completion?()
        }
    }
}
