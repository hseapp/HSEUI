//
//  HSERefreshControl.swift
//  HSEAppX
//
//  Created by Matvey Kavtorov on 8/16/20.
//  Copyright © 2020 National Research University “Higher School of Economics“. All rights reserved.
//

import UIKit

public class RefreshControl: UIRefreshControl {
    
    // MARK: - Properties
    
    public var refreshCallback: Action?
    public var verticalOffset: CGFloat = 0

    let refreshControlView: RefreshControlViewProtocol
    
    private let container: UIView
    
    // MARK: - Init

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods

    public override func addSubview(_ view: UIView) {
        if view == container { super.addSubview(view) }
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
    
    // MARK: - Private Properties

    @objc private func refresh() {
        refreshControlView.startAnimating()
        refreshCallback?()
    }
    
}

public protocol RefreshControlViewProtocol: UIView {
    
    func startAnimating()
    func stopAnimating()
    
}

// MARK: - DefaultRefreshControlView

final class DefaultRefreshControlView: UIView, RefreshControlViewProtocol {
    
    // MARK: - Private Properties
    
    private let imageView: UIImageView
    private var imageHeight: NSLayoutConstraint!
    
    private var isAnimating = false
    
    // MARK: - Init
    
    init() {
        imageView = UIImageView(image: sfSymbol("arrow.clockwise.circle.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(Color.Base.brandTint))
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.centerVertically()
        imageView.centerHorizontally()
        imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8).isActive = true
        imageHeight = imageView.height(0)
        imageView.aspectRatio()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Properties
    
    override func layoutSubviews() {
        let size = max(0, min(28, frame.height - 16))
        imageHeight.constant = size
        imageView.transform = .init(rotationAngle: size / 28 * 2)

        super.layoutSubviews()
    }
    
    func startAnimating() {
        isAnimating = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.imageView.transform = self.imageView.transform.rotated(by: .pi)
        } completion: { _ in
            guard self.isAnimating else { return }
            self.startAnimating()
        }
    }
    
    func stopAnimating() {
        isAnimating = false
    }
    
}
