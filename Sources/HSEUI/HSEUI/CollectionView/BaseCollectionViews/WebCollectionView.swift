//
//  WebCollectionView.swift
//  HSEUI
//
//  Created by Mikhail on 06.07.2021.
//

import UIKit
#if !os(watchOS)
import WebKit
#endif

protocol WebViewDataSource: AnyObject {
    func link() -> String?
}

class WebCollectionView: WKWebView, BaseCollectionViewProtocol {
    
    private weak var dataSource: WebViewDataSource?
    
    var collectionDataSource: CollectionDataSource? {
        didSet {
            dataSource = collectionDataSource?.dataSource as? WebViewDataSource
        }
    }
    
    var contentInset: UIEdgeInsets {
        set {
            scrollView.contentInset = newValue
        }
        get {
            scrollView.contentInset
        }
    }
    
    var contentSize: CGSize {
        scrollView.contentSize
    }
    
    init() {
        let config: WKWebViewConfiguration = .init()
        super.init(frame: UIScreen.main.bounds, configuration: config)
        
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        guard let link = dataSource?.link() else { return }
        if let url = URL(string: link) {
            self.load(URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 30))
        }
    }
    
}
