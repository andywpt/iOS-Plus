import UIKit

extension UICollectionView {
    
    static var `default`: Self {
        let listLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
        return self.init(frame: .zero, collectionViewLayout: listLayout)
    }

    var indexPathsForFullyVisibleItems: [IndexPath] {
        indexPathsForVisibleItems.filter {
            guard let cellFrame = layoutAttributesForItem(at: $0)?.frame else {
                return false
            }
            return bounds.contains(cellFrame)
        }
    }
}
