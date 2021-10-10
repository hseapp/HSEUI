//
//  HSERefreshControl.swift
//  HSEAppX
//
//  Created by Matvey Kavtorov on 8/16/20.
//  Copyright © 2020 National Research University “Higher School of Economics“. All rights reserved.
//

import UIKit

public class RefreshControl: UIRefreshControl {
    
    public var refreshCallback: Action?

    private let container: UIView
    
    public var verticalOffset: CGFloat = 0
    
    let refreshControlView: RefreshControlViewProtocol

    public override init() {
        container = UIView()
        refreshControlView = HSEUISettings.main.refreshControlViewClass.init()
        container.addSubview(refreshControlView)
        refreshControlView.stickToSuperviewEdges(.all)
        super.init()
        tintColor = .clear
        backgroundColor = .clear
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(container)
        addTarget(self, action: #selector(refresh), for: .valueChanged)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        clipsToBounds = false
    }
    
    public override func addSubview(_ view: UIView) {
        if view == container { super.addSubview(view) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        container.frame = CGRect(x: 0, y: verticalOffset, width: frame.width, height: frame.height)
        super.layoutSubviews()
    }

    public override func beginRefreshing() {
        super.beginRefreshing()
        refreshControlView.startAnimating()
    }
    
    public override func endRefreshing() {
        super.endRefreshing()
        refreshControlView.stopAnimating()
    }

    @objc private func refresh() {
        refreshControlView.startAnimating()
        refreshCallback?()
    }
    
}

public protocol RefreshControlViewProtocol: UIView {
    
    func startAnimating()
    
    func stopAnimating()
    
    init()
    
}

class DefaultRefreshControlView: UIView, RefreshControlViewProtocol {
    
    private let imageView: UIImageView
    
    private var imageHeight: NSLayoutConstraint!
    
    required public init() {
        imageView = UIImageView(image: sfSymbol("arrow.clockwise.circle.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(Color.Base.brandTint))
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.centerVertically()
        imageView.centerHorizontally()
        imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8).isActive = true
//        imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8).isActive = true
        imageHeight = imageView.height(0)
        imageView.aspectRatio()
    }
    
    override func layoutSubviews() {
        let size = max(0, min(28, frame.height - 16))
        
        imageHeight.constant = size
        imageView.transform = .init(rotationAngle: size / 28 * 2)

        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .repeat) {
            self.imageView.transform = self.imageView.transform.rotated(by: .pi)
        } completion: { _ in }
    }
    
    public func stopAnimating() {
        self.layer.removeAllAnimations()
    }
    
}
