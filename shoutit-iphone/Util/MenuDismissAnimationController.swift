//
//  MenuDismissAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuDismissAnimationController: MenuAnimationController {
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? MenuTableViewController
        
        let rightMargin : CGFloat = 70.0
      
        guard let fromView = fromViewController?.view else {
            fatalError()
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            guard let transitionContainer = transitionContext.containerView() else {
                fatalError()
            }
            
            if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
                fromView.frame = CGRectMake(CGRectGetWidth(transitionContainer.frame), 0, CGRectGetWidth(transitionContainer.frame) - rightMargin, CGRectGetHeight(transitionContainer.frame))
                
            } else {
                fromView.frame = CGRectMake(-CGRectGetWidth(transitionContainer.frame) + rightMargin, 0, CGRectGetWidth(transitionContainer.frame) - rightMargin, CGRectGetHeight(transitionContainer.frame))
                
            }
            
            if let overlay = fromViewController?.overlayView {
                overlay.alpha = 0
            }
            
            }) { (finished) -> Void in
                fromViewController?.overlayView = nil
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
    }
}
