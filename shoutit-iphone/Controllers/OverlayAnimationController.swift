//
//  OverlayAnimationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class OverlayAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.33
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        guard let toView = toViewController?.view else {
            fatalError("View was not created")
        }
        
        
        transitionContext.containerView.addSubview(toView)
        
        toView.alpha = 0
        toView.frame = transitionContext.containerView.frame
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
           toView.alpha = 1.0
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
        
    }
    
    func completionCurve() -> UIViewAnimationCurve {
        return .linear
    }
}
