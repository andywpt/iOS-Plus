import Combine
import SnapKit
import UIKit

class BottomSheetPresentationController: UIPresentationController {
    enum SheetHeight {
        case estimated // If the size of the of the presented view could not be computed, default to the maximum height.
        case fractionHeight(CGFloat)
    }

    init(presentedViewController: UIViewController, presenting: UIViewController?, configuration: BottomSheetTransitionConfiguration) {
        self.configuration = configuration
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    private var isShowingKeyboard = false
    private let configuration: BottomSheetTransitionConfiguration
    private var grabber: UIView!
    private var dimmingView: UIView!
    private var topAdditionalSafeAreaInset: CGFloat {
        configuration.showGrabber ? grabberMargin : 8
    }

    private var grabberMargin: CGFloat {
        let verticalSpacing: CGFloat = 12
        let grabberHeight: CGFloat = 4
        return grabberHeight + 2 * verticalSpacing
    }

    private let sheetCornerRadius: CGFloat = 23
    private var subscriptions = Set<AnyCancellable>()

    override var presentedView: UIView? {
        super.presentedView?.with {
            $0.setRoundCorners(
                radius: sheetCornerRadius,
                curve: .continuous,
                maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            )
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        print("🍄 frameOfPresentedViewInContainerView called")
        guard let presentedView else { return super.frameOfPresentedViewInContainerView }
        switch configuration.sheetHeight {
        case .estimated:
            print(containerView!.safeAreaInsets.bottom)
            print(presentedView.safeAreaInsets.bottom)
            let maxHeight = containerView!.bounds.height
                - ceil(containerView!.safeAreaInsets.top * 1.25)
                - topAdditionalSafeAreaInset
            let targetSize = CGSize(
                width: super.frameOfPresentedViewInContainerView.width,
                height: UIView.layoutFittingCompressedSize.height
            )

            var fittingHeight = presentedView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            ).height
            print("😍 fittingHeight = \(fittingHeight)")
            print("😍 Bottom inset = \(containerView!.safeAreaInsets.bottom)")
            // If the size of the of the presented view could not be computed, meaning its equal to zero, we default to the maximum height.
            if fittingHeight == .zero { fittingHeight = maxHeight }
            let adjustedSize = CGSize(
                width: super.frameOfPresentedViewInContainerView.width,
                height: min(fittingHeight, maxHeight)
                    + topAdditionalSafeAreaInset
                    + containerView!.safeAreaInsets.bottom
            )

            var adjustedOrigin = super.frameOfPresentedViewInContainerView.origin
            adjustedOrigin.y += super.frameOfPresentedViewInContainerView.height - adjustedSize.height
//            let adjustedOrigin = CGPoint(
//                x: .zero,
//                y: containerView!.frame.maxY - adjustedSize.height)
            let adjustedFrame = CGRect(origin: adjustedOrigin, size: adjustedSize)
            return adjustedFrame

        case let .fractionHeight(fraction):
            let frame = super.frameOfPresentedViewInContainerView
            let adjustedSize = CGSize(
                width: frame.size.width,
                height: frame.size.height * fraction
            )
            let adjustedOrigin = CGPoint(
                x: .zero,
                y: containerView!.frame.maxY - adjustedSize.height
            )
            let adjustedFrame = CGRect(origin: adjustedOrigin, size: adjustedSize)
            return adjustedFrame
        }
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        configureSubviews()
        configureKeyboard()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        let childSize = container.preferredContentSize
        guard childSize.height > 0 else { return }
        // print(presentedView?.window?.safeAreaInsets)
        print("😎 Child preferred height \(childSize.height)")
        let adjustedSize = CGSize(
            width: super.frameOfPresentedViewInContainerView.width,
            height: childSize.height
                + topAdditionalSafeAreaInset
                + containerView!.safeAreaInsets.bottom
        )

        var adjustedOrigin = super.frameOfPresentedViewInContainerView.origin
        adjustedOrigin.y += super.frameOfPresentedViewInContainerView.height - adjustedSize.height
//            let adjustedOrigin = CGPoint(
//                x: .zero,
//                y: containerView!.frame.maxY - adjustedSize.height)
        let adjustedFrame = CGRect(origin: adjustedOrigin, size: adjustedSize)
        UIView.performWithoutAnimation {
            presentedView!.frame = adjustedFrame
        }
    }

    private func configureSubviews() {
        if configuration.showGrabber {
            grabber = UIView().with {
                $0.backgroundColor = .systemFill
                $0.layer.cornerRadius = 2
            }
            super.presentedView!.addSubview(grabber) {
                $0.top.equalToSuperview().inset(12)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(36)
                $0.height.equalTo(4)
            }
        }
        presentedViewController.additionalSafeAreaInsets.top = topAdditionalSafeAreaInset

        dimmingView = UIView().with {
            $0.backgroundColor = UIColor(white: 0, alpha: 0.4)
            $0.alpha = 0
        }

        if configuration.tapToDismissEnabled {
            let tapGR = UITapGestureRecognizer(target: self,
                                               action: #selector(didTapOverlayView))
            dimmingView.addGestureRecognizer(tapGR)
        }

        containerView!.insertSubview(dimmingView, at: 0) {
            $0.edges.equalToSuperview()
        }
    }

    private func configureKeyboard() {
        let tap = UITapGestureRecognizer()
        tap.publisher
            .sink { _ in
                UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .store(in: &subscriptions)
        presentedView?.addGestureRecognizer(tap)
        containerView?.addGestureRecognizer(tap)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [unowned self] in
                guard presentedViewController == UIWindow.keyWindow.topLevelViewController else { return }
                guard let presentedView, let containerView else { return }
                guard let screen = presentedView.window?.windowScene?.screen else { return }
                let keyboard = $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let keyboardInView = screen.coordinateSpace.convert(keyboard, to: containerView)
                if !isShowingKeyboard {
                    isShowingKeyboard = true
                    var frame = presentedView.frame
                    frame.size.height -= containerView.safeAreaInsets.bottom
                    frame.origin.y += containerView.safeAreaInsets.bottom
                    presentedView.frame = frame
                }
                presentedView.transform = .init(translationX: 0, y: -keyboardInView.height)
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [unowned self] _ in
                guard presentedViewController == UIWindow.keyWindow.topLevelViewController else { return }
                guard let presentedView, let containerView else { return }
                if isShowingKeyboard {
                    isShowingKeyboard = false
                    var frame = presentedView.frame
                    frame.size.height += containerView.safeAreaInsets.bottom
                    frame.origin.y -= containerView.safeAreaInsets.bottom
                    presentedView.frame = frame
                }
                presentedView.transform = .identity
            }
            .store(in: &subscriptions)
    }

    @objc private func didTapOverlayView() {
        presentedViewController.presentingViewController?.dismiss(animated: true)
    }
}

// class BottomSheetPresentationController: UIPresentationController {
//
//    private let configuration = BottomSheetConfiguration()
//    private var grabber: UIView!
//    private var dimmingView: UIView!
//    private lazy var panGesture = UIPanGestureRecognizer(
//        target: self,
//        action: #selector(pannedPresentedView))
//
//    var dimmingViewTapped: (() -> Void)?
//
//    private var dismissThreshold: CGFloat {
//        configuration.dismissThreshold
//    }
//
//    override var presentedView: UIView? {
//        return super.presentedView?.with {
//            $0.layer.cornerRadius = 23
//            $0.layer.cornerCurve = .continuous
//            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        }
//    }
//
//    override var frameOfPresentedViewInContainerView: CGRect {
//        guard
//            let containerView = containerView,
//            let presentedView = presentedView
//        else {
//            return super.frameOfPresentedViewInContainerView
//        }
//        /// The maximum height allowed for the sheet. We allow the sheet to reach the top safe area inset.
//        let maximumHeight = containerView.frame.height - containerView.safeAreaInsets.top - containerView.safeAreaInsets.bottom - 200
//
//        let fittingSize = CGSize(width: containerView.bounds.width,
//                                 height: UIView.layoutFittingCompressedSize.height)
//
//        let presentedViewHeight = presentedView.systemLayoutSizeFitting(
//            fittingSize,
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        ).height
//        /// The target height of the presented view.
//        /// If the size of the of the presented view could not be computed, meaning its equal to zero, we default to the maximum height.
//        let targetHeight = presentedViewHeight == .zero ? maximumHeight : presentedViewHeight
//        /// Adjust the height of the view by adding the bottom safe area inset.
//        let adjustedHeight = min(targetHeight, maximumHeight) + 100 //+ //containerView.safeAreaInsets.bottom
//
//        let targetSize = CGSize(width: containerView.frame.width, height: adjustedHeight)
//        let targetOrigin = CGPoint(x: .zero, y: containerView.frame.maxY - targetSize.height)
//
//        return CGRect(origin: targetOrigin, size: targetSize)
//    }
//
//    override func presentationTransitionWillBegin() {
//        super.presentationTransitionWillBegin()
//        configureSubviews()
//        if let coordinator = presentedViewController.transitionCoordinator {
//            coordinator.animate(alongsideTransition: { _ in
//                self.dimmingView.alpha = 1.0
//            })
//        } else {
//            dimmingView.alpha = 1.0
//        }
//    }
//
//    private func configureSubviews(){
//
//        grabber = UIView().with {
//            $0.bounds.size = CGSize(width: 32, height: 4)
//            $0.backgroundColor = .systemFill
//        }
//
//        dimmingView = UIView().with {
//            $0.backgroundColor = UIColor(white: 0, alpha: 0.5)
//            let tapGR = UITapGestureRecognizer(target: self,
//                                                action: #selector(didTapOverlayView))
//            $0.addGestureRecognizer(tapGR)
//            $0.alpha = 0
//        }
//
//        containerView?.addSubview(dimmingView)
//        presentedView?.addSubview(grabber)
//    }
//
//    override func containerViewDidLayoutSubviews() {
//        super.containerViewDidLayoutSubviews()
//        setupLayout()
//        setupPresentedViewInteraction()
//    }
//
//    override func dismissalTransitionWillBegin() {
//        super.dismissalTransitionWillBegin()
//        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
//            guard let self = self else { return }
//            dimmingView.alpha = 0
//        })
//    }
//
//
//
//    // MARK: Private methods
//
//    private func setupLayout() {
//        guard
//            let containerView = containerView,
//            let presentedView = presentedView
//        else {
//            return
//        }
//        dimmingView.frame = containerView.bounds
//        grabber.frame.origin.y = 8
//        grabber.center.x = presentedView.center.x
//        grabber.layer.cornerRadius = grabber.frame.height / 2
//        presentedView.layer.cornerCurve = .continuous
//        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        presentedViewController.additionalSafeAreaInsets.top = 100//pullBarView.frame.maxY
//    }
//
//    private func setupPresentedViewInteraction() {
//        guard let presentedView = presentedView else { return }
//        presentedView.addGestureRecognizer(panGesture)
//    }
//
//    private func dismiss(interactively isInteractive: Bool) {
//        transition.wantsInteractiveStart = isInteractive
//        presentedViewController.dismiss(animated: true)
//    }
//
//    @objc private func didTapOverlayView() {
//        dismiss(interactively: false)
//    }
//
//    @objc private func pannedPresentedView(_ recognizer: UIPanGestureRecognizer) {
//        switch recognizer.state {
//        case .began:
//            dismiss(interactively: true)
//        case .changed:
//            let view = recognizer.view!
//            let dragAmount = max(recognizer.translation(in: view).y, 0)
//            let adjustedHeight = view.frame.height - dragAmount
//            let progress = 1 - (adjustedHeight / view.frame.height)
//            transition.update(progress)
//
//        case .ended, .cancelled:
//            let view = recognizer.view!
//            let dragSpeed = recognizer.velocity(in: view).y
//            if transition.dismissFractionComplete > 0.5 || dragSpeed > 450 {
//                transition.finish()
//            } else {
//                transition.cancel()
//            }
//        default:
//            break
//        }
//    }
// }
