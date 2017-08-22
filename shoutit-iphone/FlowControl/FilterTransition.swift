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
        case presenting
        case dismissing
    }
    
    // consts
    fileprivate let animationDuration: TimeInterval = 0.33
    fileprivate let topSpace: CGFloat = {
        let screenHeight = UIScreen.main.bounds.height
        let filterViewHeight: CGFloat = min(503, screenHeight)
        return screenHeight - filterViewHeight
    }()
    
    // state
    fileprivate var transitionDirection: TransitionDirection = .presenting
    fileprivate weak var presentedViewController: UIViewController?
    
    // views
    fileprivate var blurOverlay: UIVisualEffectView!
}

extension FilterTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get view controllers
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let sourceRect = transitionContext.initialFrame(for: fromVC)
        
        switch transitionDirection {
        case .presenting:
            
            fromVC.view.isUserInteractionEnabled = false
            fromVC.view.frame = sourceRect
            
            presentedViewController = toVC
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FilterTransition.handleTap))
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FilterTransition.handlePan(_:)))
            blurOverlay = UIVisualEffectView(frame: sourceRect)
            blurOverlay.addGestureRecognizer(tapGesture)
            blurOverlay.addGestureRecognizer(panGesture)
            let transitionContainer = transitionContext.containerView
            
            transitionContainer.addSubview(blurOverlay)
            transitionContainer.addSubview(toVC.view)
            
            let startFrame = CGRect(x: 0, y: fromVC.view.frame.height , width: fromVC.view.frame.width, height: fromVC.view.frame.height - topSpace)
            let endFrame = CGRect(x: 0, y: topSpace, width: fromVC.view.frame.width, height: fromVC.view.frame.height - topSpace)
            toVC.view.frame = startFrame
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                toVC.view.frame = endFrame
                self.blurOverlay.effect = UIBlurEffect(style: .dark)
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
            
        case .dismissing:
            
            toVC.view.isUserInteractionEnabled = true
            
            let transitionContainer = transitionContext.containerView
            
            transitionContainer.addSubview(blurOverlay)
            transitionContainer.addSubview(fromVC.view)
            
            let endFrame = CGRect(x: 0, y: toVC.view.frame.height , width: toVC.view.frame.width, height: toVC.view.frame.height - topSpace)
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                fromVC.view.frame = endFrame
                self.blurOverlay.effect = nil
                }, completion: { (finished) in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}

extension FilterTransition: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionDirection = .presenting
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionDirection = .dismissing
        return self
    }
}

extension FilterTransition {
    
    func handleTap() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        if gestureRecognizer.velocity(in: view).y > 50 {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
