//
//  MenuDismissAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class MenuDismissAnimationController: MenuAnimationController {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? MenuTableViewController
        
        let rightMargin : CGFloat = 70.0
      
        guard let fromView = fromViewController?.view else {
            fatalError()
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            let transitionContainer = transitionContext.containerView
            
            if (UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft) {
                fromView.frame = CGRect(x: transitionContainer.frame.width, y: 0, width: transitionContainer.frame.width - rightMargin, height: transitionContainer.frame.height)
                
            } else {
                fromView.frame = CGRect(x: -transitionContainer.frame.width + rightMargin, y: 0, width: transitionContainer.frame.width - rightMargin, height: transitionContainer.frame.height)
                
            }
            
            if let overlay = fromViewController?.overlayView {
                overlay.alpha = 0
            }
            
            }, completion: { (finished) -> Void in
                fromViewController?.overlayView = nil
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
        
    }
}
