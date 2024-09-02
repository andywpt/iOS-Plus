import UIKit

extension UITabBarAppearance {
    
    func withBackgroundColor(_ color: UIColor) -> Self {
        with {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = color
        }
    }
    
    func withTintColor(normal: UIColor, selected: UIColor) -> Self {
        configureItemAppearance {
            $0.normal.iconColor = normal
            $0.normal.titleTextAttributes = [.foregroundColor: normal]
            $0.selected.iconColor = selected
            $0.selected.titleTextAttributes = [.foregroundColor: selected]
        }
    }
    
    func withIconColor(normal: UIColor, selected: UIColor) -> Self {
        configureItemAppearance {
            $0.normal.iconColor = normal
            $0.selected.iconColor = selected
        }
    }
    
    func withBadgeColor(_ color: UIColor) -> Self {
        configureItemAppearance {
            $0.normal.badgeBackgroundColor = color
            $0.selected.badgeBackgroundColor = color
        }
    }
    
    private func configureItemAppearance(configuration: (UITabBarItemAppearance) -> Void) -> Self {
        let itemAppearances = [
            stackedLayoutAppearance,
            inlineLayoutAppearance,
            compactInlineLayoutAppearance,
        ]
        itemAppearances.forEach(configuration)
        return self
    }
}
