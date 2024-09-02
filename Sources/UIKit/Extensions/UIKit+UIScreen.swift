import UIKit

extension UIScreen {
    static var shared: UIScreen {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first!.screen
    }
}
