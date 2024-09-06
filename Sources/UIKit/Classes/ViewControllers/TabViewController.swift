import UIKit
import Combine

protocol TabViewModel {
    var title: String { get }
    var image: UIImage? { get }
    var selectedImage: UIImage? { get }
    var badgeText: AnyPublisher<String?,Never>? { get }
}

final class TabViewController: ContentWrapperController {
    
    private let viewModel: any TabViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    init(viewModel: any TabViewModel){
        self.viewModel = viewModel
        super.init()
        bindViewModel()
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
