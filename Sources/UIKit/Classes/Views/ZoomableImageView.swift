import UIKit
import Combine

class ZoomableImageView: UIImageView {
    
    var didStartZooming: (() -> ())?
    var didEndZooming: (() -> ())?
    
    var prev: CGPoint!
    var oneFinger = false
    var onePrev: CGPoint!
   
    let maxOverlayAlpha: CGFloat = 0.8
    let minOverlayAlpha: CGFloat = 0.2
    
    private lazy var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
    var overlayView: UIView!
    var windowImageView: UIImageView?
    var initialGestureInView: CGPoint!
    
    private var subscriptions = Set<AnyCancellable>()
    private var ratioConstraint: NSLayoutConstraint!
    private let maxContentRatio: CGFloat = 5/4
    private let minContentRatio: CGFloat = 1/3
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func commonInit(){
        backgroundColor = .white
        contentMode = .scaleAspectFit
        addGestureRecognizer(pinchGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func pinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = frame.size.width / bounds.size.width
            let newScale = currentScale * sender.scale
            if newScale > 1 {
                guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                didStartZooming?()
                
                overlayView = UIView(frame: currentWindow.bounds)
                overlayView.backgroundColor = .black
                overlayView.alpha = 0
                currentWindow.addSubview(overlayView)

                windowImageView = UIImageView(image: image)
                windowImageView?.backgroundColor = backgroundColor
                windowImageView?.frame = convert(bounds, to: currentWindow)
                windowImageView?.contentMode = contentMode
                windowImageView?.clipsToBounds = true
                windowImageView?.accessibilityIgnoresInvertColors = true
                currentWindow.addSubview(windowImageView!)

                alpha = 0
                initialGestureInView = sender.location(in: sender.view)
            }
          
        } else if sender.state == .changed {
    
            if sender.numberOfTouches >= 2 {
                print("TWO FINGER")
                oneFinger = false
                prev = sender.location(in: sender.view)
            }

            let shift = CGPoint(x: initialGestureInView.x - bounds.midX,
                               y: initialGestureInView.y - bounds.midY)
            var delta: CGPoint

            if sender.numberOfTouches < 2 {
                if !oneFinger{
                    oneFinger = true
                    print("switch to one finger")
                    onePrev = sender.location(in: sender.view)
                    delta = CGPoint(x: prev.x - initialGestureInView.x,
                                    y: prev.y - initialGestureInView.y)
                }else{
                    print("one finger ")
                    let dx = sender.location(in: sender.view).x - onePrev.x
                    let dy = sender.location(in: sender.view).y - onePrev.y
                    delta = CGPoint(x: prev.x + dx - initialGestureInView.x,
                                   y: prev.y + dy - initialGestureInView.y)
                }
            }else{
                print("two finger")
                delta = CGPoint(x: sender.location(in: sender.view).x  - initialGestureInView.x,
                                y: sender.location(in: sender.view).y - initialGestureInView.y)
            }

            let currentScale = windowImageView!.frame.width / windowImageView!.bounds.width

            let senderScale = (currentScale > 4) ? (sender.scale > 1) ? 1 : sender.scale : sender.scale
            let newScale = currentScale * senderScale
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha

            let zoomScale = (newScale * windowImageView!.frame.width >= frame.width) ? newScale : currentScale

            let transform = CGAffineTransform.identity
                .translatedBy(x: delta.x, y: delta.y)
                .translatedBy(x: shift.x , y: shift.y )
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -shift.x , y: -shift.y)
            //.translatedBy(x: centerXDif / zoomScale, y: centerYDif / zoomScale)
              
            windowImageView?.transform = transform
            
            sender.scale = 1

        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
           
            guard let windowImageView = windowImageView else { return }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: .curveEaseInOut) {
                windowImageView.transform = CGAffineTransform.identity
                self.overlayView.alpha = 0
            }completion: { _ in
                windowImageView.removeFromSuperview()
                self.overlayView.removeFromSuperview()
                self.alpha = 1
                self.didEndZooming?()
            }
        }
    }
}
