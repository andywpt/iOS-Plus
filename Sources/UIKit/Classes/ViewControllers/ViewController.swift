#if canImport(UIKit)
import UIKit

class ViewController<View>: UIViewController where View: UIView {
    
    final var mainView: View { view as! View }
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    // Marking it unavailable also removes the need to write it again when subclassing
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    final override func loadView() {
        view = View()
    }
}
#endif
