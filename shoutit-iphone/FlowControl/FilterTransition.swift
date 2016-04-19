//
//  FilterTransition.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class FilterTransition: NSObject {
    
    enum TransitionDirection {
        case Presenting
        case Dismissing
    }
    
    // consts
    private let animationDuration: NSTimeInterval = 0.33
    private let topSpace: CGFloat = {
        let screenHeight = UIScreen.mainScreen().bounds.height
        let filterViewHeight: CGFloat = min(503, screenHeight)
        return screenHeight - filterViewHeight
    }()
    
    // state
    private var transitionDirection: TransitionDirection = .Presenting
    private weak var presentedViewController: UIViewController?
    
    // views
    private var blurOverlay: UIVisualEffectView!
}

extension FilterTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Get view controllers
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let sourceRect = transitionContext.initialFrameForViewController(fromVC)
        
        switch transitionDirection {
        case .Presenting:
            
            fromVC.view.userInteractionEnabled = false
            fromVC.view.frame = sourceRect
            
            presentedViewController = toVC
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FilterTransition.handleTap))
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FilterTransition.handlePan(_:)))
            blurOverlay = UIVisualEffectView(frame: sourceRect)
            blurOverlay.addGestureRecognizer(tapGesture)
            blurOverlay.addGestureRecognizer(panGesture)
            let transitionContainer = transitionContext.containerView()!
            
            transitionContainer.addSubview(blurOverlay)
            transitionContainer.addSubview(toVC.view)
            
            let startFrame = CGRect(x: 0, y: fromVC.view.frame.height , width: fromVC.view.frame.width, height: fromVC.view.frame.height - topSpace)
            let endFrame = CGRect(x: 0, y: topSpace, width: fromVC.view.frame.width, height: fromVC.view.frame.height - topSpace)
            toVC.view.frame = startFrame
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: [.CurveEaseInOut], animations: {
                toVC.view.frame = endFrame
                self.blurOverlay.effect = UIBlurEffect(style: .Dark)
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
            
        case .Dismissing:
            
            toVC.view.userInteractionEnabled = true
            
            let transitionContainer = transitionContext.containerView()!
            
            transitionContainer.addSubview(blurOverlay)
            transitionContainer.addSubview(fromVC.view)
            
            let endFrame = CGRect(x: 0, y: toVC.view.frame.height , width: toVC.view.frame.width, height: toVC.view.frame.height - topSpace)
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: [.CurveEaseInOut], animations: {
                fromVC.view.frame = endFrame
                self.blurOverlay.effect = nil
                }, completion: { (finished) in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}

extension FilterTransition: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionDirection = .Presenting
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionDirection = .Dismissing
        return self
    }
}

extension FilterTransition {
    
    func handleTap() {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        if gestureRecognizer.velocityInView(view).y > 50 {
            presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
