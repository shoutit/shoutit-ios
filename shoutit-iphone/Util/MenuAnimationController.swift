//
//  MenuAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? MenuTableViewController
        let rightMargin : CGFloat = 70.0
        let menuInsets = UIEdgeInsetsMake(-1, -1, 2, 0)
        
        var overlayView : UIView {
            get {
                let v = UIView()
                v.frame = (transitionContext.containerView()?.bounds)!
                v.backgroundColor = UIColor.blackColor()
                v.alpha = 0
                return v
            }
        }
        
        guard let toView = toViewController?.view else {
            fatalError("View was not created")
        }
        
        let overlay = overlayView
        
        toViewController?.overlayView = overlay
        transitionContext.containerView()?.addSubview(overlay)
        transitionContext.containerView()?.addSubview(toView)
        
        toView.alpha = 1
        
        let width = CGRectGetWidth(transitionContext.containerView()!.frame)
        let destinationRect : CGRect!
        
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            toView.frame = CGRectMake(width, 0, width - rightMargin, CGRectGetHeight(transitionContext.containerView()!.frame))
            destinationRect = CGRectMake(rightMargin + menuInsets.left + menuInsets.right, menuInsets.top, width - rightMargin + menuInsets.right, CGRectGetHeight(transitionContext.containerView()!.frame) + menuInsets.bottom)
        } else {
            toView.frame = CGRectMake(-width + rightMargin, 0, width - rightMargin, CGRectGetHeight(transitionContext.containerView()!.frame))
            destinationRect = CGRectMake(menuInsets.left, menuInsets.top, CGRectGetWidth(transitionContext.containerView()!.frame) - rightMargin + menuInsets.right, CGRectGetHeight(transitionContext.containerView()!.frame) + menuInsets.bottom)
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            
            toView.frame = destinationRect
            overlay.alpha = 0.3
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func completionCurve() -> UIViewAnimationCurve {
        return .Linear
    }
}
