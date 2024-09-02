import UIKit

// You can scroll in code, and you can do so even if the user can’t scroll. The content moves to the position you specify, with no bouncing and no exposure of the scroll indicators. You can specify the new position in two ways:
// scrollRectToVisible(_:animated:)
// Adjusts the content so that the specified CGRect of the content is within the scroll view’s bounds. This is imprecise, because you’re not saying exactly what the resulting scroll position will be, but sometimes guaranteeing the visibility of a certain portion of the content is exactly what you’re after.
// contentOffset
// A property signifying the point (CGPoint) of the content that is located at the scroll view’s top left (effectively the same thing as the scroll view’s bounds ori‐ gin). Setting it changes the current scroll position, or call setContent- Offset(_:animated:) to set the contentOffset with animation. The values normally go up from (0.0,0.0) until the limit dictated by the contentSize and the scroll view’s own bounds size is reached.
// The adjustedContentInset (discussed in the previous section) can affect the mean‐ ing of the contentOffset. Recall the scenario where the scroll view underlaps the sta‐ tus bar and a navigation bar and acquires an adjustedContentInset with a top of 64. Then when the scroll view’s content is scrolled all the way down, the contentOffset is not (0.0,0.0) but (0.0,-64.0). The (0.0,0.0) point is the top of the content rect, which is located at the bottom of the navigation bar; the point at the top left of the scroll view itself is 64 points above that.
// That fact manifests itself particularly when you want to scroll, in code. If you scroll by setting the contentOffset, you need to subtract the corresponding adjustedContent- Inset value. Staying with our scroll view that underlaps a navigation bar, if your goal is to scroll the scroll view so that the top of its content is visible, you do not say this (the scroll view is self.sv):
//     self.sv.contentOffset.y = 0
//   432 | Chapter 7: Scroll Views
// Instead, you say this:
//     self.sv.contentOffset.y = -self.sv.adjustedContentInset.top

extension UIScrollView {
    var contentOffsetMaxY: CGFloat {
        contentSize.height - bounds.height + adjustedContentInset.bottom
    }

    var contentOffsetMinY: CGFloat {
        -adjustedContentInset.top
    }

    var contentOffsetMaxX: CGFloat {
        contentSize.width - bounds.width + adjustedContentInset.left
    }

    var minimumContentOffset: CGPoint {
        CGPoint(
            x: -adjustedContentInset.left,
            y: -adjustedContentInset.top
        )
    }

    var maximumContentOffset: CGPoint {
        CGPoint(
            x: contentSize.width - bounds.width + adjustedContentInset.left,
            y: contentSize.height - bounds.height + adjustedContentInset.bottom
        )
    }
}
