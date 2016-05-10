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
        
        let constraints = Array(self.currentControllerConstraints.dropLast(4))
        self.containerView.removeConstraints(constraints)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()
        controller.didMoveToParentViewController(self)
        self.currentChildViewController = controller
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