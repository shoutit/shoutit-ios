//
//  OverlayDismissAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class OverlayDismissAnimationController: OverlayAnimationController {
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        guard let fromView = fromViewController?.view else {
            fatalError()
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            guard let _ = transitionContext.containerView() else {
                fatalError()
            }
            
            fromView.alpha = 0.0
            
            
            }) { (finished) -> Void in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
    }
}
