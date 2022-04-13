//
//  LargeTitleController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 2/15/22.
//

import UIKit
import HSEUI

class LargeTitleController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Large title"
//        HSEUISettings.main.setRefreshControlClass(HSERefreshControlView.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let collectionView = CollectionView(type: .list)
    
    private var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        collectionView.setUpRefresher { [weak self] in
            print("refreshing!")
            mainQueue(delay: 3) {
                self?.reload()
            }
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        reload()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.tintColor = Color.Base.brandTint
        searchController?.searchBar.searchTextField.tokenBackgroundColor = Color.Base.brandTint
        searchController?.searchBar.returnKeyType = .search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func reload() {
        collectionView.reload(with: collectionViewModel())
    }
    
    func collectionViewModel() -> CollectionViewModelProtocol {
        return CollectionViewModel(cells: [])
    }
    
}

class DummyTarget {
    
    private let callback: Action
    
    init(callback: @escaping Action) {
        self.callback = callback
    }
    
    @objc func target() {
        callback()
    }
    
}

public class HSERefreshControlView: UIView, RefreshControlViewProtocol {
    
    private let imageView: UIImageView
    
    private let loader = LoaderView()

    private let images: [UIImage] = [
//        UIImage(named: "nointernet", in: .current, with: .none)!,
//        UIImage(named: "nodata", in: .current, with: .none)!,
//        UIImage(named: "hse24", in: .current, with: .none)!.withTintColor(Color.Base.brandTint).withRenderingMode(.alwaysTemplate),
//        UIImage(named: "accountChoice", in: resourceBundle, with: .none)!
        sfSymbol("clock.arrow.2.circlepath")!
    ]
    
    required public init() {
        imageView = UIImageView(image: images.randomElement())
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(loader)
    }
    
    private var isStateExpired = false
    
    private func resetState() {
        if Int.random(in: 0...9) == 0 {
            imageView.alpha = 1
//            imageView.image = images.filter{ imageView.image != $0 }.randomElement()
            loader.isHidden = true
        } else {
            imageView.alpha = 0
            loader.isHidden = false
        }
        isStateExpired = false
    }
    
    public override func layoutSubviews() {
        let size = max(0, min(42, frame.height - 16))
        let elementFrame = CGRect(x: frame.width/2 - size/2, y: frame.height/2 - size/2, width: size, height: size)
        imageView.frame = elementFrame
        loader.frame = frame
        if frame.height < 16 {
            if isStateExpired {
                resetState()
            }
        } else {
            isStateExpired = true
        }
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.12
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]

        self.imageView.layer.add(animationGroup, forKey: "pulse")
        
        self.loader.startAnimating()
    }
    
    public func stopAnimating() {
        self.loader.stopAnimating()
        self.imageView.layer.removeAllAnimations()
    }
    
}

private class LoaderView: UIView {
    
    private var link: CADisplayLink? {
        didSet {
            if let old = oldValue {
                old.remove(from: .current, forMode: .common)
            }
            link?.add(to: .current, forMode: .common)
        }
    }
    
    public func startAnimating() {
        state = .animating
        link = CADisplayLink(target: DummyTarget { [weak self] in
            self?.update()
        }, selector: #selector(DummyTarget.target))
    }
    
    public func stopAnimating() {
        state = .finished
        let currentLink = self.link
        mainQueue(delay: 0.3, block: {
            if currentLink == self.link {
                self.link = nil
            }
        })
    }
    
    private enum State {
        case ready
        case animating
        case finished
    }
    
    private var state: State = .ready
    
    private var currentDirection: CGFloat = 1
    
    private let progressSpeedStep: CGFloat = 1 / 60
    
    private let rotationSpeedStep: CGFloat = .pi / 60
    
    override var frame: CGRect {
        didSet {
            if self.state == .ready {
                self.update()
            } else if frame.size.height < 16 && state != .animating {
                self.state = .ready
            }
        }
    }
    
    func update() {
        switch state {
        case .ready:
            progress = max(0, min(1, (frame.height / 158)))
            alpha = max(0, min(1, frame.height / 158))
        case .animating:
            alpha = alpha * 0.5 + 0.5
            progress = progress * 0.9 + 0.7 * 0.1
            if progress >= 1 || progress <= 0.6 { currentDirection = -currentDirection }
            progress = max(0, min(1, progress))
        case .finished:
            progress = min(1, progress + progressSpeedStep * 2)
            alpha = max(0, alpha - 0.05)
        }
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var rotation: CGFloat = 0
    
    private var progress: CGFloat = 0
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        switch state {
        case .animating, .finished:
            rotation += rotationSpeedStep
        default:
            break
        }
        
        Color.Base.brandTint.setStroke()
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = min(12, max(2, rect.height / 2 - 9))
        
        let archPath = UIBezierPath()
        archPath.addArc(withCenter: center, radius: radius, startAngle: rotation, endAngle: rotation + .pi * 2 * progress, clockwise: true)
        archPath.lineWidth = 3
        archPath.lineCapStyle = .round
        archPath.stroke()
    }
    
}
