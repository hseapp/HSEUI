import UIKit

public protocol CellViewModelProtocol: AnyObject {
    var id: Int { get }
    var selectionBlock: ((Bool) -> Bool)? { set get }
    var isSelected: Bool { set get }
    var isEditable: Bool { get }
    var preferredAnimation: UITableView.RowAnimation? { get }
    
    func initView() -> UIView
    func updateView(view: UIView?) -> Bool
    func getCell(for collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func getCell(for tableView: UITableView, indexPath: IndexPath, kind: UITableView.ElementKind) -> UIView
    func willBeDisplayed(viewModel: CollectionViewModel)
    func leadingSwipeActions() -> [UIContextualAction]
    func trailingSwipeActions() -> [UIContextualAction]
    func configure(for view: CollectionView)
    func getCellView() -> UIView?
    func update(cell: BaseCellProtocol, collectionView: CollectionView)
    
    func highlight(backgroundColor: UIColor,
                   with highlightColor: UIColor,
                   overallDuration: TimeInterval)
    
    func preferredHeight(for parentHeight: CGFloat) -> CGFloat?
    func preferredWidth(for parentWidth: CGFloat) -> CGFloat?
}

/// Link to `CellViewModel` for `BaseCell`
public protocol CellViewModelItem: AnyObject {
    func reset()
}

