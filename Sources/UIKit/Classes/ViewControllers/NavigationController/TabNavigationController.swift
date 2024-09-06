import UIKit
import Combine

protocol TabViewModel {
    var title: String { get }
    var image: UIImage? { get }
    var selectedImage: UIImage? { get }
    var badgeText: AnyPublisher<String?,Never>? { get }
}

class TabNavigationController: MinimalBackButtonNavigationController {
    
    private let viewModel: any TabViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    init(viewModel: any TabViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func bindViewModel(){
        tabBarItem.title = viewModel.title
        tabBarItem.image = viewModel.image
        tabBarItem.selectedImage = viewModel.selectedImage
        viewModel.badgeText?
            .sink { [weak self] in self?.tabBarItem.badgeValue = $0 }
            .store(in: &subscriptions)
    }
}
