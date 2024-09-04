#if canImport(UIKit) && canImport(SnapKit)
import UIKit
import SnapKit

private final class PromptView: UIView {
    
    private init(views: [UIView], padding: UIEdgeInsets = .init(top: 12, left: 16, bottom: 16, right: 16)) {
        super.init(frame: .zero)
        let stackView = UIStackView().with {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
        }
        stackView.addArrangedSubviews(views)
        addSubview(stackView){
            $0.edges.equalToSuperview().inset(padding)
        }
        setRoundCorners(radius: 10, curve: .continuous)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func show(in containerView: UIView, animated: Bool = true) {
        guard let window = containerView.window, window.isKeyWindow else { return }
        
        let topView = window.topLevelViewController.view!
        topView.subviews
            .compactMap{ $0 as? PromptView }
            .forEach { $0.dismiss(animated: false) }
        topView.addSubview(self){
            $0.center.equalTo(topView.safeAreaLayoutGuide)
        }
        if animated {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0) {
                self.transform = .identity
            }
        }
    }
    
    private func dismiss(animated: Bool = true) {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.alpha = 0
                },
                completion: { _ in
                    self.removeFromSuperview()
                }
            )
        }else {
            removeFromSuperview()
        }
    }
}

extension PromptView {
    
    @discardableResult
    static func showError(in containerView: UIView, message: String) -> PromptView {
        let image = UIImage(systemName: "exclamationmark.circle")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 19, weight: .light))
        return Self.show(
            text: message,
            image: image,
            in: containerView,
            foregroundColor: UIColor.white,
            backgroundColor: UIColor(hex: 0x262626)
        )
    }
    
    @discardableResult
    static func show(
        text: String,
        image: UIImage?,
        in containerView: UIView,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = UIColor(hex: 0xF6F6F6),
        duration: TimeInterval = 1.5
    ) -> PromptView {
        
        let label = UILabel().with {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = foregroundColor
            $0.numberOfLines = 0
            $0.text = text
        }
        label.addConstraints {
            $0.width.lessThanOrEqualTo(containerView.frame.width * 0.5)
        }
        let imageView = UIImageView().with {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.tintColor = foregroundColor
            $0.image = image
        }
        imageView.addConstraints {
            $0.size.equalTo(32)
        }
        let prompt = PromptView(views: [imageView,label]).with {
            $0.backgroundColor = backgroundColor
        }
        prompt.show(in: containerView)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            prompt.dismiss()
        }
        return prompt
    }
}

extension UIView {
    
    func showErrorPrompt(message: String) {
        PromptView.showError(in: self, message: message)
    }
    
//    AlertView.show(text: "已加入收藏", image: UIImage(systemName: "heart")?.withConfiguration(UIImage.SymbolConfiguration(weight: .thin)), in: mainView)
}
#endif
