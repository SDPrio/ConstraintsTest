import UIKit
import AVFoundation


extension UIView {
    func setAnchorConstraints(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superview = superview {
            for constraint in superview.constraints {
                if
                    (constraint.firstAnchor == superview.topAnchor && constraint.secondAnchor == topAnchor) ||
                    (constraint.firstAnchor == superview.leadingAnchor && constraint.secondAnchor == leadingAnchor) ||
                    (constraint.firstAnchor == superview.bottomAnchor && constraint.secondAnchor == bottomAnchor) ||
                    (constraint.firstAnchor == superview.trailingAnchor && constraint.secondAnchor == trailingAnchor) ||
                        
                    (constraint.firstAnchor == topAnchor && constraint.secondAnchor == superview.topAnchor) ||
                    (constraint.firstAnchor == leadingAnchor && constraint.secondAnchor == superview.leadingAnchor) ||
                    (constraint.firstAnchor == bottomAnchor && constraint.secondAnchor == superview.bottomAnchor) ||
                    (constraint.firstAnchor == trailingAnchor && constraint.secondAnchor == superview.trailingAnchor)
                {
                    superview.removeConstraint(constraint)
                }
            }
            
            if let top = top {
                topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
            }
            
            if let left = left {
                leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left).isActive = true
            }
            
            if let bottom = bottom {
                bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom).isActive = true
            }
            

            if let right = right {
                trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -right).isActive = true
            }
        }
    }
    
    
    func setFillConstraints() {
        setAnchorConstraints(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    

    
    // Move all subviews into a new (sub-)view while keeping the constraints intact.
    func moveSubviewsIntoView(_ targetView: UIView) {
        // Check wether the target view is already a (direct or indirect) subview of this view
        var targetChildView: UIView? = targetView
        while targetChildView != nil {
            if targetChildView?.superview == self {
                break;
            } else {
                targetChildView = targetChildView?.superview
            }
        }
        
        var targetViewConstraintsToAdd = [NSLayoutConstraint]()
        var targetViewConstraintsToActivate = [NSLayoutConstraint]()
        
        for subview in subviews {
            if subview == targetChildView {
                // Skip target view or its parent which is a subview of this view.
                continue
            }
            
            // Check all constraints if they have to be moved
            for constraint in constraints {
                if let newConstraint = moveConstraint(constraint, ofView: subview, fromView: self, toView: targetView) {
                    let active = constraint.isActive
                    
                    constraint.isActive = false
                    removeConstraint(constraint)
                    
                    targetViewConstraintsToAdd.append(newConstraint)
                    if active {
                        targetViewConstraintsToActivate.append(newConstraint)
                    }
                }
            }
            
            targetView.addSubview(subview)
        }
        
        targetView.addConstraints(targetViewConstraintsToAdd)
        for constraint in targetViewConstraintsToActivate {
            constraint.isActive = true
        }
    }
    
    private func moveConstraint(_ constraint: NSLayoutConstraint, ofView view: UIView, fromView prevSuperview: UIView, toView newSuperview: UIView) -> NSLayoutConstraint? {
        // Check if the constraint is reladed to the superview or its layout guides
        var prevSuperviewIsFirstItem: Bool = constraint.firstItem === prevSuperview
        if !prevSuperviewIsFirstItem {
            for layoutGuide in prevSuperview.layoutGuides {
                if constraint.firstItem === layoutGuide {
                    prevSuperviewIsFirstItem = true
                    break
                }
            }
        }
        
        var prevSuperviewIsSecondItem: Bool = constraint.secondItem === prevSuperview
        if !prevSuperviewIsSecondItem {
            for layoutGuid in prevSuperview.layoutGuides {
                if constraint.secondItem === layoutGuid {
                    prevSuperviewIsSecondItem = true
                    break
                }
            }
        }
        
        
        // Create a new constraints relative to the new superview if necessary
        var newConstraint: NSLayoutConstraint? = nil
        if prevSuperviewIsFirstItem && constraint.secondItem === view {
            newConstraint = NSLayoutConstraint(item: newSuperview, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: view, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
        } else if prevSuperviewIsSecondItem && constraint.firstItem === view {
            newConstraint = NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: newSuperview, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
        }
        
        
        // Apply futher properties to new constraint.
        if let newConstraint = newConstraint {
            //newConstraint.identifier = constraint.identifier
            //newConstraint.shouldBeArchived = constraint.shouldBeArchived
            newConstraint.priority = constraint.priority
            return newConstraint
        }
        
        
        // Return original constraint if it is related the moved view (= constraint between the moved
        // view and other subviews of the superview)
        if constraint.firstItem === view || constraint.secondItem === view {
            return constraint
        }
        
        return nil
    }
    
    
    func dumpConstraints(inset: String = "") {
        print("\(inset)\(type(of: self)) - \(Unmanaged.passUnretained(self).toOpaque())")
        for constraint in constraints {
            print("\(inset)  \(constraint.description)")
        }
        /*for layoutGuide in layoutGuides {
            print("\(inset)  \(layoutGuide.description)")
        }*/
        for subview in subviews {
            subview.dumpConstraints(inset: "\(inset)\t")
        }
    }
    
    
    
    
    // =============================================================================================
    //  Animations
    // =============================================================================================
    func shake(vibrate: Bool = false) {
        let shakeLeft = CGAffineTransform.identity.translatedBy(x: 2.0, y: -2.0)
        let shakeRight = CGAffineTransform.identity.translatedBy(x: -2.0, y: 2.0)

        transform = shakeLeft
        
        UIView.animate(withDuration: 0.05,
        animations: {
            UIView.setAnimationRepeatAutoreverses(true)
            UIView.setAnimationRepeatCount(3)

            self.transform = shakeRight
        }) { completed in
            self.transform = CGAffineTransform.identity
        }
        
        if (vibrate) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
