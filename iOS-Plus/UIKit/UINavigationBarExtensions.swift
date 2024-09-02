import UIKit

extension UINavigationBar {
    var shadowColor: UIColor? {
        get { standardAppearance.shadowColor }
        set {
            let appearance = standardAppearance.with { $0.shadowColor = newValue }
            setAppearance(appearance)
        }
    }

    // Do not use the backgroundColor property to configure the navigation bar
    var barBackgroundColor: UIColor? {
        get { standardAppearance.backgroundColor }
        set {
            let appearance = standardAppearance.with { $0.backgroundColor = newValue }
            setAppearance(appearance)
        }
    }

    func setDefaultAppearance() {
        let defaultAppearance = UINavigationBarAppearance().with {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
            $0.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            ]
            $0.buttonAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            ]
            $0.buttonAppearance.highlighted.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            ]
            let backImage = UIImage(systemName: "arrow.left")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
            $0.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }
        setAppearance(defaultAppearance)
    }

    private func setAppearance(_ appearance: UINavigationBarAppearance) {
        standardAppearance = appearance
        compactAppearance = appearance
        scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            compactScrollEdgeAppearance = appearance
        }
    }
}
