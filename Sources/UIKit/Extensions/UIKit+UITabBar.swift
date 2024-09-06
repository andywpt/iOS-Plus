import UIKit

extension UITabBar {
    
    func setBackgroundColor(_ color: UIColor) {
        standardAppearance.with {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = color
        }
        syncAppearances()
    }
    
    func setTintColor(normal: UIColor, selected: UIColor) {
        configureItemAppearance {
            $0.normal.iconColor = normal
            $0.normal.titleTextAttributes = [.foregroundColor: normal]
            $0.selected.iconColor = selected
            $0.selected.titleTextAttributes = [.foregroundColor: selected]
        }
        syncAppearances()
    }
    
    func setIconColor(normal: UIColor, selected: UIColor) {
        configureItemAppearance {
            $0.normal.iconColor = normal
            $0.selected.iconColor = selected
        }
        syncAppearances()
    }
    
    func setBadgeColor(_ color: UIColor) {
        configureItemAppearance {
            $0.normal.badgeBackgroundColor = color
            $0.selected.badgeBackgroundColor = color
        }
        syncAppearances()
    }
    
    private func syncAppearances() {
        if #available(iOS 15.0, *) {
            scrollEdgeAppearance = standardAppearance
        }
    }
    
    private func configureItemAppearance(configuration: (UITabBarItemAppearance) -> Void) {
        let itemAppearances = [
            standardAppearance.stackedLayoutAppearance,
            standardAppearance.inlineLayoutAppearance,
            standardAppearance.compactInlineLayoutAppearance,
        ]
        itemAppearances.forEach(configuration)
    }
}
