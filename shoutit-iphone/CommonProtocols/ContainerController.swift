//
//  ContainerController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ContainerController {
    var animationDuration: Double {get}
    var containerView: UIView! {get}
}

extension ContainerController where Self: UIViewController {
    
    func addInitialViewController(viewController: UIViewController) {
        
        addChildViewController(viewController)
        addSubview(viewController.view, toView: containerView)
        viewController.view.layoutIfNeeded()
        viewController.didMoveToParentViewController(self)
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController, animated: Bool) {
        
        // prepare for transition
        oldViewController.willMoveToParentViewController(nil)
        addChildViewController(newViewController)
        
        //
        newViewController.view.alpha = 0.0
        addSubview(newViewController.view, toView: containerView)
        newViewController.view.layoutIfNeeded()
        
        let animationClosure = {
            newViewController.view.alpha = 1.0
            oldViewController.view.alpha = 0.0
        }
        
        let completionClosure: (Bool) -> Void = {(_) -> Void in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMoveToParentViewController(self)
        }
        
        if animated {
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: [], animations: animationClosure, completion: completionClosure)
        } else {
            animationClosure()
            completionClosure(true)
        }
    }
    
    func addSubview(subview: UIView, toView view: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let views = ["subview" : subview]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: [], metrics: nil, views: views))
    }
}