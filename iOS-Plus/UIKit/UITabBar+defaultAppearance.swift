import UIKit

extension UITabBarAppearance {
    static var defaultAppearance: UITabBarAppearance {
        let appearance = UITabBarAppearance().with {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
        }
        let badgeColor = UIColor.systemYellow
        let itemAppearances = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance,
        ]

        itemAppearances.forEach {
            $0.normal.iconColor = .black
            $0.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
            // $0.normal.badgeBackgroundColor = badgeColor

            $0.selected.iconColor = .black
            $0.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
        return appearance
    }
}
