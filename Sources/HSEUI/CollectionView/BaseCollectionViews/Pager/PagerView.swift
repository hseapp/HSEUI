import UIKit

final class PagerView: UIScrollView {
    
    // MARK: - Private Properties

    private var subviewsConstraints: [NSLayoutConstraint?] = []
    
    // MARK: - Internal Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentSize.width = CGFloat(subviews.count) * frame.width
    }

    func updateSubviews() {
        subviewsConstraints.forEach({$0?.isActive = false})
        subviewsConstraints.removeAll()

        var lastView: UIView?
        for i in 0..<subviews.count {
            subviewsConstraints.append(
                subviews[i].widthAnchor.constraint(equalTo: widthAnchor)
            )
            subviewsConstraints.append(
                subviews[i].heightAnchor.constraint(equalTo: heightAnchor)
            )
            subviewsConstraints.append(
                subviews[i].topAnchor.constraint(equalTo: topAnchor, constant: contentInset.top)
            )

            if let lastView = lastView {
                subviewsConstraints.append(
                    subviews[i].leftAnchor.constraint(equalTo: lastView.rightAnchor)
                )
            } else {
                subviewsConstraints.append(
                    subviews[i].leftAnchor.constraint(equalTo: leftAnchor)
                )
            }
            lastView = subviews[i]
        }
        subviewsConstraints.append(
            lastView?.rightAnchor.constraint(equalTo: rightAnchor)
        )
        subviewsConstraints.forEach({$0?.isActive = true})
    }

}
