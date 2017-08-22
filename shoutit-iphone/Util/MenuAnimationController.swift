//
//  MenuAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.33
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? MenuTableViewController
        let rightMargin : CGFloat = 70.0
        let menuInsets = UIEdgeInsetsMake(-1, -1, 2, 0)
        
        var overlayView : UIView {
            get {
                let v = UIView()
                v.frame = (transitionContext.containerView.bounds)
                v.backgroundColor = UIColor.black
                v.alpha = 0
                return v
            }
        }
        
        guard let toView = toViewController?.view else {
            fatalError("View was not created")
        }
        
        let overlay = overlayView
        
        toViewController?.overlayView = overlay
        transitionContext.containerView.addSubview(overlay)
        transitionContext.containerView.addSubview(toView)
        
        toView.alpha = 1
        
        let width = transitionContext.containerView.frame.width
        let destinationRect : CGRect!
        
        if (UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft) {
            toView.frame = CGRect(x: width, y: 0, width: width - rightMargin, height: transitionContext.containerView.frame.height)
            destinationRect = CGRect(x: rightMargin + menuInsets.left + menuInsets.right, y: menuInsets.top, width: width - rightMargin + menuInsets.right, height: transitionContext.containerView.frame.height + menuInsets.bottom)
        } else {
            toView.frame = CGRect(x: -width + rightMargin, y: 0, width: width - rightMargin, height: transitionContext.containerView.frame.height)
            destinationRect = CGRect(x: menuInsets.left, y: menuInsets.top, width: transitionContext.containerView.frame.width - rightMargin + menuInsets.right, height: transitionContext.containerView.frame.height + menuInsets.bottom)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            
            toView.frame = destinationRect
            overlay.alpha = 0.3
            }, completion: { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
    
    func completionCurve() -> UIViewAnimationCurve {
        return .linear
    }
}
