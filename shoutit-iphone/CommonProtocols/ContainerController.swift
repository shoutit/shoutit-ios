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
    
    func changeContentTo(_ controller: UIViewController, animated: Bool = false) {
        
        guard currentChildViewController !== controller else { return }
        
        currentChildViewController?.willMove(toParentViewController: nil)
        addChildViewController(controller)
        addSubview(controller.view, toView: containerView)
        
        let constraints = Array(self.currentControllerConstraints.dropLast(4))
        self.containerView.removeConstraints(constraints)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()
        controller.didMove(toParentViewController: self)
        self.currentChildViewController = controller
    }
    
    fileprivate func addSubview(_ subview: UIView, toView view: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let views = ["child" : subview]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[child]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[child]|", options: [], metrics: nil, views: views)
        view.addConstraints(constraints)
        currentControllerConstraints += constraints
    }
}
