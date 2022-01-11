//
//  Skeleton.swift
//  HSEUI
//
//  Created by Matvey Kavtorov on 3/5/21.
//

import UIKit
import HSEUI

public class SkeletonManager {
    
    public static var isEnabled: Bool = false
    
    static let main = SkeletonManager()
    
    private var cache: [String: SkeletonTree] = [:]
    
    func readSkeleton<T>(for vc: T) where T: UIViewController {
        guard SkeletonManager.isEnabled else { return }
        guard let view = vc.view else { return }
        guard let tree = try? view.getSkeletonTree() else { return }
        guard tree.isValid else { return }
        saveTree(tree: tree, file: identifier(for: vc))
    }
    
    func getSkeleton<T>(for vc: T) -> UIView? where T: UIViewController {
        guard SkeletonManager.isEnabled else { return nil }
        guard let tree = getTree(file: identifier(for: vc)) else { return nil }
        return SkeletonView(tree: tree)
    }
    
    private func identifier(for controller: UIViewController) -> String {
        let orientation = UIDevice.current.orientation.rawValue
        let hasParent = controller.parent != nil
        return String(describing: controller.classForCoder) + "\(orientation)-\(hasParent)"
    }
    
    private func saveTree(tree: SkeletonTree, file: String) {
        cache[file] = tree
        if let data = try? JSONEncoder().encode(tree) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(file).skeleton")
            try? data.write(to: filename)
        }
    }
    
    private func getTree(file: String) -> SkeletonTree? {
        let filename = getDocumentsDirectory().appendingPathComponent("\(file).skeleton")
        if let result = cache[file] { return result }
        guard let data = FileManager.default.contents(atPath: filename.path) else { return nil }
        return try? JSONDecoder().decode(SkeletonTree.self, from: data)
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension UIView {
    
    fileprivate var elementType: SkeletonTree.ElementType {
        if (self is UILabel ||
            self is UIImageView ||
            self is UITextView ||
            self is UIButton ||
            self is UITextField ||
            self.layer.cornerRadius > 0
        ) && !self.isHidden &&
            self.alpha > 0 &&
            self.frame.height >= 4 &&
            self.frame.width >= 4 {
            return .element
        } else {
            return .empty
        }
    }
    
    fileprivate var shouldBeRemoved: Bool {
        if self is UIRefreshControl || self is UIActivityIndicatorView {
            return true
        }
        return false
    }
    
    fileprivate func getSkeletonTree() throws -> SkeletonTree {
        if blocksSkeletonisation { throw NSError(domain: "view blocked skeletonisations", code: 100500, userInfo: nil)}
        var children: [SkeletonTree] = []
        if elementType != .element {
            children = try subviews.filter{ !$0.shouldBeRemoved }.map { try $0.getSkeletonTree() }
        }
        return SkeletonTree(type: elementType, frame: frame, radius: layer.cornerRadius, maskedCorners: layer.maskedCorners, children: children)
    }
    
    @objc open var blocksSkeletonisation: Bool {
        return false
    }
    
}

extension CACornerMask: Codable { }

class SkeletonTree: Codable {
    
    enum ElementType: String, Codable {
        case empty
        case element
    }
    
    let type: ElementType
    
    let frame: CGRect
    
    let radius: CGFloat

    let maskedCorners: CACornerMask
    
    let children: [SkeletonTree]
    
    init(type: ElementType, frame: CGRect, radius: CGFloat, maskedCorners: CACornerMask, children: [SkeletonTree]) {
        self.type = type
        self.frame = frame
        self.radius = radius
        self.maskedCorners = maskedCorners
        self.children = children
    }
    
    var isValid: Bool {
        return numberOfBlocks >= 5
    }
    
    private var numberOfBlocks: Int {
        switch type {
        case .element:
            return 1
        case .empty:
            return children.reduce(into: 0, { $0 += $1.numberOfBlocks })
        }
    }
    
}

public class SkeletonView: UIView {
    
    init(tree: SkeletonTree) {
        super.init(frame: .zero)
        addSubview(SkeletonNodeView(tree: tree))
        backgroundColor = Color.Base.mainBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class SkeletonNodeView: UIView {
    
    init(tree: SkeletonTree) {
        super.init(frame: tree.frame)
        switch tree.type {
            case .element:
                backgroundColor = Color.Base.skeleton
                shimmer()
            case .empty:
                backgroundColor = Color.Base.mainBackground
        }
        layer.cornerRadius = max(2, tree.radius)
        layer.maskedCorners = tree.maskedCorners
        tree.children.forEach {
            addSubview(SkeletonNodeView(tree: $0))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shimmer() {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: -0.02)
        gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width*3, height: self.bounds.size.height)

        let lowerAlpha: CGFloat = 0.8
        let solid = UIColor(white: 1, alpha: 1).cgColor
        let clear = UIColor(white: 1, alpha: lowerAlpha).cgColor
        gradient.colors     = [ solid, solid, clear, clear, solid, solid ]
        gradient.locations  = [ 0,     0.3,   0.45,  0.55,  0.7,   1     ]

        let theAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        theAnimation.duration = 1
        theAnimation.repeatCount = Float.infinity
        theAnimation.autoreverses = true
        theAnimation.isRemovedOnCompletion = false
        theAnimation.fillMode = CAMediaTimingFillMode.forwards
        theAnimation.fromValue = -self.frame.size.width * 2
        theAnimation.toValue =  0
        gradient.add(theAnimation, forKey: "animateLayer")

        self.layer.mask = gradient
    }
    
}
