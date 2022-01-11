import UIKit
import HSEUI

// MARK: - BottomPagePresentable
protocol __BottomPagePresentable: UIView {
    var menuOptionsTop: NSLayoutConstraint? { get }
    var menuOptionsHeight: CGFloat { get }
    var menuOptionsView: MenuOptionsCollectionView { get }
    var pagerView: CollectionView { get }
    var pagerDelegate: PagerDelegate? { set get }
    
    func reload(cells: [ListsCollection.BottomPageModel], selectorTitles: [String], animated: Bool)
    func setMenuOptionsVisible()
    func orientationWillChange(newSize: CGSize)
}

// MARK: - BottomPageContainerView
extension ListsCollection {
    
    typealias BottomPagePresentable = __BottomPagePresentable
    
    class BottomPageContainerView: UIView, BottomPagePresentable {
        
        /// this enum is used to prevent blinking when user selects page which index differs from the current one by 2 or more
        enum MenuOptionsState {
            case `default`, wait(Int)
        }
        
        // MARK: - menu options
        var menuOptionsView: MenuOptionsCollectionView = .init()
        
        private var menuOptionsViewModel: CollectionViewModel?
        
        private var selectorTitles: [String] = [] {
            didSet {
                menuOptionsHeight = selectorTitles.isEmpty ? 0 : 48
            }
        }
        
        var menuOptionsHeight: CGFloat = 0 {
            didSet {
                pagerViewTop?.constant = menuOptionsHeight
            }
        }
        
        var menuOptionsTop: NSLayoutConstraint?
        
        private var menuOptionsState: MenuOptionsState = .default
        
        // MARK: - pager
        var pagerView: CollectionView = .init(type: .pager)
        
        var currentIndex: Int = 0
        
        var pagerDelegate: PagerDelegate?
        
        var pagerViewTop: NSLayoutConstraint?
        
        // MARK: - init
        init() {
            super.init(frame: .zero)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - set up
        private func commonInit() {
            backgroundColor = .clear
            pagerView.backgroundColor = .clear
            
            menuOptionsView.isHidden = true
            pagerView.pagerDelegate = self
            
            addSubview(pagerView)
            pagerView.stickToSuperviewEdges([.left, .right, .bottom])
            pagerViewTop = pagerView.top(0)
            
            addSubview(menuOptionsView)
            menuOptionsTop = menuOptionsView.stickToSuperviewEdges([.left, .right, .top])?.top
        }
        
        
        // MARK: - BottomPagePresentable
        func reload(cells: [ListsCollection.BottomPageModel], selectorTitles: [String], animated: Bool) {
            self.selectorTitles = selectorTitles
            
            pagerView.reload(with: CollectionViewModel(cells: cells), animated: animated)
            
            if !selectorTitles.isEmpty {
                setUpMenuOptions()
                menuOptionsView.collectionView.reload(with: menuOptionsViewModel!, animated: false)
                menuOptionsView.isHidden = false
            } else {
                menuOptionsView.isHidden = true
            }
            menuOptionsView.collectionHeightConstraint?.constant = menuOptionsHeight
            layoutIfNeeded()
        }
        
        func setMenuOptionsVisible() {
            menuOptionsViewModel?.setCellVisible.raise(data: IndexPath(row: currentIndex, section: 0))
        }
        
        func orientationWillChange(newSize: CGSize) {
            pagerView.orientationWillChange(newSize: newSize)
        }
        
    }
    
}

// MARK: - MenuOptions
extension ListsCollection.BottomPageContainerView {
    
    private func setUpMenuOptions() {
        var cells: [MenuOptionViewModel] = []
        for (i, title) in selectorTitles.enumerated() {
            cells.append(MenuOptionViewModel(option: title, tapCallback: { [weak self] in
                guard self?.currentIndex != i else { return }
                self?.menuOptionsState = .wait(i)
                self?.pagerView.changePage(newIndex: i, animated: true)
            }))
        }
        menuOptionsViewModel = CollectionViewModel(cells: cells, selectionStyle: .picker)
        
        if currentIndex < selectorTitles.count {
            self.menuOptionsViewModel?.sections.first?.cells[currentIndex].isSelected = true
        } else {
            self.menuOptionsViewModel?.sections.first?.cells.first?.isSelected = true
        }
    }
    
}

// MARK: - PagerDelegate
extension ListsCollection.BottomPageContainerView: PagerDelegate {
    
    func pageDidChange(_ index: Int) {
        currentIndex = index
        pagerDelegate?.pageDidChange(index)
        updateMenuOptions(for: index)
    }
    
    private func updateMenuOptions(for index: Int) {
        if case .wait(let newIndex) = menuOptionsState {
            if newIndex != index { return }
            menuOptionsState = .default
        }
        
        if let cells = self.menuOptionsViewModel?.sections.first?.cells {
            if index >= 0 && index < cells.count {
                cells[index].isSelected = true
            }
        }
        setMenuOptionsVisible()
    }
    
}

