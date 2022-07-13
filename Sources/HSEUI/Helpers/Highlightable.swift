import UIKit

public protocol Highlightable {
    func highlight(backgroundColor: UIColor,
                   with highlightColor: UIColor,
                   overallDuration: TimeInterval)
}

extension Highlightable {
    public func highlight(backgroundColor: UIColor = Color.Base.mainBackground,
                   with highlightColor: UIColor = Color.Base.selection,
                   overallDuration: TimeInterval = 1.0) {
        highlight(backgroundColor: backgroundColor, with: highlightColor, overallDuration: overallDuration)
    }
}
