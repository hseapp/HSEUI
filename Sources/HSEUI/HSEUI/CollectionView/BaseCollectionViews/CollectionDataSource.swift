import Foundation

class CollectionDataSource {
    
    init (_ dataSource: NSObjectProtocol) {
        self.dataSource = dataSource
    }
    
    weak var dataSource: NSObjectProtocol?
    
}
