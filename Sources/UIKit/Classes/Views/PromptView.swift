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
        containerView.addSubview(self){
            $0.center.equalTo(containerView.safeAreaLayoutGuide)
        }
        if animated {
            self.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
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
            foregroundColor: UIColor.white.withAlphaComponent(0.9),
            backgroundColor: UIColor.black.withAlphaComponent(0.9)
        )
    }
    
    @discardableResult
    static func show(
        text: String,
        image: UIImage?,
        in containerView: UIView,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = UIColor(hex: 0xF6F6F6),
        duration: TimeInterval = 1.3
    ) -> PromptView {
        let label = UILabel().with {
            $0.font = .systemFont(ofSize: 15, weight: .medium)
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
            $0.size.equalTo(38)
        }
        let toast = PromptView(views: [imageView,label]).with {
            $0.backgroundColor = backgroundColor
        }
        toast.show(in: containerView)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            toast.dismiss()
        }
        return toast
    }
}

extension UIView {
    
    func showErrorPrompt(message: String) {
        PromptView.showError(in: self, message: message)
    }
    
//    AlertView.show(text: "已加入收藏", image: UIImage(systemName: "heart")?.withConfiguration(UIImage.SymbolConfiguration(weight: .thin)), in: mainView)
}
#endif
