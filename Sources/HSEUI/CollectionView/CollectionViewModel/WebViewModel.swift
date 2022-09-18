#if !os(watchOS)
import WebKit
#endif

open class WebViewModel: CollectionViewModel {
    
    public var link: String
    
    public init(link: String) {
        self.link = link
        super.init()
    }
    
    public override func copy() -> CollectionViewModelProtocol {
        WebViewModel(link: link)
    }
    
}
