import UIKit

extension Array where Element == CellViewModel {
    
    func highlight(backgroundColor: UIColor = Color.Base.mainBackground,
                   with highlightColor: UIColor = Color.Base.selection,
                   overallDuration: TimeInterval = 1.0) {
        self.forEach { viewModel in
            viewModel.highlight(backgroundColor: backgroundColor, with: highlightColor, overallDuration: overallDuration)
        }
    }
    
}
