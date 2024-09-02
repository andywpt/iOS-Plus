import Foundation

struct BottomSheetTransitionConfiguration {
    private(set) var sheetHeight: BottomSheetPresentationController.SheetHeight
    private(set) var dragToDismissEnabled: Bool = true
    private(set) var tapToDismissEnabled: Bool = true
    private(set) var showGrabber: Bool = false
}
