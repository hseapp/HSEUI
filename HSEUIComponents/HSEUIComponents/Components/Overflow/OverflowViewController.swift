import UIKit
import HSEUI

open class OverflowViewController: CollectionViewController {
    
    private let data: OverflowData
    
    private let position: OverflowViewModel.Position
    
    public init(data: OverflowData, position: OverflowViewModel.Position = .top(), tapCallback: Action? = nil) {
        var dataCopy = data
        dataCopy.addTapCallback(tapCallback, position: 0)
        self.data = dataCopy
        self.position = position
        
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func collectionViewModel() -> CollectionViewModelProtocol {
        let cell: OverflowViewModel = .init(data: data, position: position)
        return CollectionViewModel(cell: cell)
    }
    
}


