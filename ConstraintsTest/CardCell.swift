import UIKit

@IBDesignable class CardCell: UICollectionViewCell {
    private var containerView: UIView!
    private var clippingView: UIView!
    
    @objc dynamic var insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) {
        didSet {
            containerView?.setAnchorConstraints(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
    
    @IBInspectable public var bottomInset: CGFloat {
        get { return insets.bottom }
        set { insets.bottom = newValue }
    }
    @IBInspectable public var leftInset: CGFloat {
        get { return insets.left }
        set { insets.left = newValue }
    }
    @IBInspectable public var rightInset: CGFloat {
        get { return insets.right }
        set { insets.right = newValue }
    }
    @IBInspectable public var topInset: CGFloat {
        get { return insets.top }
        set { insets.top = newValue }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.1
    @IBInspectable var shadowRadius: CGFloat = 3
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 1, height: 1)
    @IBInspectable var shadowColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.white
                } else {
                    return UIColor.black
                }
            }
        } else {
            return UIColor.black
        }
    }()
    
    @IBInspectable dynamic var cornerRadius: CGFloat = 10
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        
        // The cell holds all its content inside the contentView. To create a card layout two
        // additional wrapper views are used:
        //    Cell
        //       - contentView
        //          - containerView (creates the shadow and margins)
        //             - clippingView (used to create rounded corners)
        //
        // All subviews need to be moved to the clipping view while keeping the constraints
        // intact.
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.setAnchorConstraints(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
        
        containerView.backgroundColor = UIColor.clear
        /*containerView.layer.shadowOpacity = shadowOpacity
        containerView.layer.shadowRadius = shadowRadius
        containerView.layer.shadowColor = shadowColor.cgColor
        containerView.layer.shadowOffset = shadowOffset*/
        
        
        clippingView = UIView()
        clippingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(clippingView)
        clippingView.setFillConstraints()
        clippingView.layer.cornerRadius = (cornerRadius > 0 ? (cornerRadius < 1 ? clippingView.frame.height * cornerRadius : cornerRadius) : 0)
        clippingView.layer.masksToBounds = true
        isSelected = self.isSelected
        
        clippingView.backgroundColor = backgroundColor
        backgroundColor = .clear
        
        print("===============")
        self.dumpConstraints()
        
        contentView.moveSubviewsIntoView(clippingView)
        
        print("--------------")
        self.dumpConstraints()
        print("===============")
    }
}
