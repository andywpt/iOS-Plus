import UIKit

extension UINavigationBar {
    /// Do not use the backgroundColor property to configure the navigation bar
    func setBackgroundColor(_ color: UIColor){
        standardAppearance.with {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = color
        }
        updateAllAppearances()
    }

    func setShadowColor(_ color: UIColor){
        standardAppearance.with { $0.shadowColor = color }
        updateAllAppearances()
    }
    
    func setBackButtonImage(_ image: UIImage?){
        standardAppearance.with {
            $0.setBackIndicatorImage(image, transitionMaskImage: image)
        }
        updateAllAppearances()
    }
    
    func setBarButtonItemFont(_ font: UIFont) {
        standardAppearance.with {
            $0.buttonAppearance.normal.titleTextAttributes[.font] = font
            $0.buttonAppearance.highlighted.titleTextAttributes[.font] = font
        }
        updateAllAppearances()
    }
    
    func setBarButtonItemTintColor(_ color: UIColor) {
        standardAppearance.with {
            $0.buttonAppearance.normal.titleTextAttributes[.foregroundColor] = color
            $0.buttonAppearance.highlighted.titleTextAttributes[.foregroundColor] = color
        }
        updateAllAppearances()
    }
    
    func setTitleFont(_ font: UIFont){
        standardAppearance.with {
            $0.titleTextAttributes[.font] = font
        }
        updateAllAppearances()
    }
    
    func setTitleColor(_ color: UIColor){
        standardAppearance.with {
            $0.titleTextAttributes[.foregroundColor] = color
        }
        updateAllAppearances()
    }

    private func updateAllAppearances() {
        compactAppearance = standardAppearance
        scrollEdgeAppearance = standardAppearance
        if #available(iOS 15.0, *) {
            compactScrollEdgeAppearance = standardAppearance
        }
    }
}
