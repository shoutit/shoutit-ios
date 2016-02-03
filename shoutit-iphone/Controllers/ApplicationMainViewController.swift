//
//  ApplicationMainViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ApplicationMainViewControllerRootObject: class {
    
}

final class ApplicationMainViewController: UIViewController, ContainerController {
    
    // consts
    let animationDuration: Double = 0.25
    var containerView: UIView! {
        return view
    }
    
    // vars
    private(set) var rootObject: ApplicationMainViewControllerRootObject!
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
    
    private(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func showLogin() {
        let navigationController = UINavigationController()
        rootObject = LoginFlowController(navigationController: navigationController)
        rootViewController = navigationController
    }
    
    private func showMainInterface() {
        let rootController = Wireframe.mainInterfaceViewController()
        rootObject = rootController
        rootViewController = rootController
    }
}
