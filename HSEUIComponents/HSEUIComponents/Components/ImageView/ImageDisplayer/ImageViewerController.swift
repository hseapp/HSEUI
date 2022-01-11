import UIKit
import HSEUI

class ImageViewerController: UIViewController {
    
    class ImageDisplayerImageView: ImageView {
        var completion: Action?
        override func layoutSubviews() {
            super.layoutSubviews()
            completion?()
        }
    }
    
    let index: Int
    
    private let imageItem: ImageItem
    
    var imageView: ImageDisplayerImageView = {
        let iv = ImageDisplayerImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        return iv
    }()
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.backgroundColor = .clear
        return sv
    }()

    var backgroundView: UIView? {
        (parent as? ImageDisplayerViewController)?.backgroundView
    }

    var navBar: UINavigationBar? {
        (parent as? ImageDisplayerViewController)?.navBar
    }
    
    private var imageConstraints: AnchoredConstraints?
    
    private var lastLocation: CGPoint = .zero
    private var isAnimating: Bool = false
    private var maxZoomScale: CGFloat = 1.0
    
    init(
        index: Int,
        imageItem:ImageItem) {
        
        self.index = index
        self.imageItem = imageItem
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navBar?.alpha = 1.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navBar?.alpha = 0.0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func commonInit() {
        view.addSubview(scrollView)
        scrollView.stickToSuperviewEdges(.all)
        
        scrollView.addSubview(imageView)
        imageConstraints = imageView.stickToSuperviewEdges(.all)
        
        addGestureRecognizers()
        setImage()
        
        imageView.completion = { [weak self] in
            self?.layout()
        }
    }
    
    private func layout() {
        guard imageView.bounds.size != .zero else { return }
        updateConstraintsForSize(view.bounds.size)
        updateMinMaxZoomScaleForSize(view.bounds.size)
        imageView.completion = nil
    }
    
    private func setImage() {
        switch imageItem {
        case .image(let img):
            imageView.image = img
            imageView.layoutIfNeeded()
        case .link(let link):
            imageView.loadImage(link) { [weak self] (success) in
                if success {
                    self?.imageView.layoutIfNeeded()
                    self?.updateConstraintsForSize(self?.view.bounds.size ?? .zero)
                }
            }
        }
    }
    
    // MARK: Add Gesture Recognizers
    private func addGestureRecognizers() {
        
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(didPan(_:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)
        
        let pinchRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didPinch(_:)))
        pinchRecognizer.numberOfTapsRequired = 1
        pinchRecognizer.numberOfTouchesRequired = 2
        scrollView.addGestureRecognizer(pinchRecognizer)
        
        let singleTapGesture = UITapGestureRecognizer(
            target: self, action: #selector(didSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapGesture.require(toFail: doubleTapRecognizer)
    }
    
    @objc private func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard
            isAnimating == false,
            scrollView.zoomScale == scrollView.minimumZoomScale
            else { return }
        
        let container: UIView = imageView
        if gestureRecognizer.state == .began {
            lastLocation = container.center
        }
        
        if gestureRecognizer.state != .cancelled {
            let translation: CGPoint = gestureRecognizer.translation(in: view)
            container.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        }
        
        let diffY = view.center.y - container.center.y
        backgroundView?.alpha = 1.0 - abs(diffY / view.center.y)
        if gestureRecognizer.state == .ended {
            if abs(diffY) > 60 {
                dismiss(animated: true)
            } else {
                executeCancelAnimation()
            }
        }
    }
    
    @objc private func didPinch(_ recognizer: UITapGestureRecognizer) {
        var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale)
        scrollView.setZoomScale(newZoomScale, animated: true)
    }
    
    @objc private func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        let currentNavAlpha = self.navBar?.alpha ?? 0.0
        UIView.animate(withDuration: 0.235) {
            self.navBar?.alpha = currentNavAlpha > 0.5 ? 0.0 : 1.0
        }
    }
    
    @objc private func didDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        zoomInOrOut(at: pointInView)
    }
    
}

extension ImageViewerController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            scrollView.zoomScale == scrollView.minimumZoomScale,
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer
            else { return false }
        
        let velocity = panGesture.velocity(in: scrollView)
        return abs(velocity.y) > abs(velocity.x)
    }
    
}

// MARK: Adjusting the dimensions
extension ImageViewerController {
    
    private func updateMinMaxZoomScaleForSize(_ size: CGSize) {
        let targetSize = imageView.bounds.size
        if targetSize.width == 0 || targetSize.height == 0 {
            return
        }
        
        let minScale = min(size.width/targetSize.width, size.height/targetSize.height)
        let maxScale = max((size.width + 1.0) / targetSize.width, (size.height + 1.0) / targetSize.height)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        maxZoomScale = maxScale
        scrollView.maximumZoomScale = maxZoomScale * 1.1
    }
    
    private func zoomInOrOut(at point:CGPoint) {
        let newZoomScale = scrollView.zoomScale == scrollView.minimumZoomScale
            ? maxZoomScale : scrollView.minimumZoomScale
        let size = scrollView.bounds.size
        let w = size.width / newZoomScale
        let h = size.height / newZoomScale
        let x = point.x - (w * 0.5)
        let y = point.y - (h * 0.5)
        let rect = CGRect(x: x, y: y, width: w, height: h)
        scrollView.zoom(to: rect, animated: true)
    }
    
    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageConstraints?.top?.constant = yOffset
        imageConstraints?.bottom?.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageConstraints?.leading?.constant = xOffset
        imageConstraints?.trailing?.constant = xOffset
        view.layoutIfNeeded()
    }
    
}

// MARK: Animation Related stuff
extension ImageViewerController {
    
    private func executeCancelAnimation() {
        self.isAnimating = true
        UIView.animate(
            withDuration: 0.237,
            animations: {
                self.imageView.center = self.view.center
                self.backgroundView?.alpha = 1.0
        }) { _ in
            self.isAnimating = false
        }
    }
    
}

extension ImageViewerController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}
