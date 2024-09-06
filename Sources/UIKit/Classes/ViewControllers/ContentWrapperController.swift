import SnapKit
import UIKit

class ContentWrapperController: UIViewController {
    
    var viewController: UIViewController? { children.first }
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    // Marking it unavailable also removes the need to write it again when subclassing
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func show(_ newChild: UIViewController, animation: ReplaceAnimation, completion: (() -> Void)? = nil) {
        if let fromVC = children.first {
            addChild(newChild)
            fromVC.willMove(toParent: nil)
            transition(from: fromVC, to: newChild, duration: animation.duration, options: animation.options) {
                newChild.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            } completion: { _ in
                newChild.didMove(toParent: self)
                fromVC.removeFromParent()
                completion?()
            }
        } else {
            addChild(newChild)
            view.addSubview(newChild.view) { $0.edges.equalToSuperview() }
            newChild.didMove(toParent: self)
            completion?()
        }
    }
}

extension ContentWrapperController {
    enum ReplaceAnimation {
        case none
        case crossDissolve
        case flipFromLeft
        case flipFromRight

        var duration: TimeInterval {
            switch self {
            case .none: 0
            case .crossDissolve: 0.2
            case .flipFromLeft: 0.4
            case .flipFromRight: 0.4
            }
        }

        var options: UIView.AnimationOptions {
            switch self {
            case .none: []
            case .crossDissolve: .transitionCrossDissolve
            case .flipFromLeft: .transitionFlipFromLeft
            case .flipFromRight: .transitionFlipFromRight
            }
        }
    }
}
