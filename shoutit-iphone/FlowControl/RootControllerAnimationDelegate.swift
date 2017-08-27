//
//  RootControllerAnimationDelegate.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 29.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class RootControllerAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = presented as? MenuTableViewController {
            return MenuAnimationController()
        }
        
        return OverlayAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = dismissed as? MenuTableViewController {
            return MenuDismissAnimationController()
        }
        
        return OverlayDismissAnimationController()
    }
}
