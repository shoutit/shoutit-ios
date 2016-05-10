//
//  ContainerController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ContainerController: class {
    
    var animationDuration: Double {get}
    
    var containerView: UIView! {get}
    weak var currentChildViewController: UIViewController? { get set }
    var currentControllerConstraints: [NSLayoutConstraint] { get set }
}

// MARK: - Default values

extension ContainerController {
    var animationDuration: Double { return 0.0 }
}

extension ContainerController where Self: UIViewController {
    
    func changeContentTo(controller: UIViewController, animated: Bool = false) {
        
        guard currentChildViewController !== controller else { return }
        
        currentChildViewController?.willMoveToParentViewController(nil)
        
        addChildViewController(controller)
        
        addSubview(controller.view, toView: containerView)
        //controller.view.alpha = 0.0
        //controller.view.layoutIfNeeded()
        
        //controller.view.alpha = 1.0
        //self.currentChildViewController?.view.alpha = 0.0
        
        let constraints = Array(self.currentControllerConstraints.dropLast(4))
        self.containerView.removeConstraints(constraints)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()
        controller.didMoveToParentViewController(self)
        self.currentChildViewController = controller
        
        return
        
        let animationClosure = {[weak self] in
            controller.view.alpha = 1.0
            self?.currentChildViewController?.view.alpha = 0.0
        }
        
        let completionClosure: (Bool) -> Void = {[weak self](_) -> Void in
            guard let `self` = self else { return }
            let constraints = Array(self.currentControllerConstraints.dropLast(4))
            self.containerView.removeConstraints(constraints)
            self.currentChildViewController?.view.removeFromSuperview()
            self.currentChildViewController?.removeFromParentViewController()
            controller.didMoveToParentViewController(self)
            self.currentChildViewController = controller
        }
        
        if animated {
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: [], animations: animationClosure, completion: completionClosure)
        } else {
            animationClosure()
            completionClosure(true)
        }
    }
    
    private func addSubview(subview: UIView, toView view: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let views = ["child" : subview]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[child]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[child]|", options: [], metrics: nil, views: views)
        view.addConstraints(constraints)
        currentControllerConstraints += constraints
    }
}