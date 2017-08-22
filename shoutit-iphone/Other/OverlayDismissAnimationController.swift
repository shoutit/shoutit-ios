//
//  OverlayDismissAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class OverlayDismissAnimationController: OverlayAnimationController {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        guard let fromView = fromViewController?.view else {
            fatalError()
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            guard let _ = transitionContext.containerView else {
                fatalError()
            }
            
            fromView.alpha = 0.0
            
            
            }, completion: { (finished) -> Void in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
        
    }
}
