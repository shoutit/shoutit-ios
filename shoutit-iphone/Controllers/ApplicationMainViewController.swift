//
//  ApplicationMainViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ApplicationMainViewController: UIViewController {
    
    // consts
    let animationDuration = 0.25
    
    // vars
    private(set) var rootViewController: UIViewController! {
        
        didSet {
            
            guard let rootViewController = rootViewController else {
                fatalError("Can't set nil root view controller")
            }
            
            if let oldViewController = oldValue {
                cycleFromViewController(oldViewController, toViewController: rootViewController, animated: true)
            } else {
                addInitialViewController(rootViewController)
            }
        }
    }
    
    // MARK: - Lifecycle
    
    final override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Transitioning
    
    private func addInitialViewController(viewController: UIViewController) {
        
        addChildViewController(viewController)
        addSubview(viewController.view, toView: view)
        viewController.view.layoutIfNeeded()
        viewController.didMoveToParentViewController(self)
    }
    
    private func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController, animated: Bool) {
        
        // prepare for transition
        oldViewController.willMoveToParentViewController(nil)
        addChildViewController(newViewController)
        
        //
        newViewController.view.alpha = 0.0
        addSubview(newViewController.view, toView: view)
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
    
    private func addSubview(subview: UIView, toView view: UIView) {
        
        view.addSubview(subview)
        
        let views = ["subview" : subview]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: [], metrics: nil, views: views))
    }
}
