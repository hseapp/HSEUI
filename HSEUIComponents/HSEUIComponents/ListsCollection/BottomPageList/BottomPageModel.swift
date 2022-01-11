import UIKit
import HSEUI

extension ListsCollection {
    
    final class BottomPageModel: CellViewModel {
        
        private var viewModel: CollectionViewModelProtocol?
        
        init(viewModel: CollectionViewModelProtocol?) {
            self.viewModel = viewModel
            
            if viewModel is CollectionViewModel {
                super.init(view: ListView.self)
                
                let configurator = CellViewConfigurator<ListView>.builder()
                    .setConfigureView({ [weak self] in $0.reload(with: self?.viewModel) })
                    .build()
                
                updateConfigurator(configurator)
            } else {
                super.init(view: WebView.self)
                
                let configurator = CellViewConfigurator<WebView>.builder()
                    .setConfigureView({ [weak self] in $0.reload(with: self?.viewModel) })
                    .build()
                
                updateConfigurator(configurator)
            }
        }
        
        func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool = false) {
            self.viewModel = viewModel
            
            if viewModel is WebViewModel {
                apply(type: WebView.self) { [weak self] view in
                    view.reload(with: self?.viewModel, animated: animated)
                }
            } else {
                apply(type: ListView.self) { [weak self] view in
                    view.reload(with: self?.viewModel, animated: animated)
                }
            }
        }
        
    }
    
}
