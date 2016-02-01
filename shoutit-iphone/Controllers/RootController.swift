//
//  RootController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class RootController: UIViewController {
        
    @IBOutlet weak var contentContainer : UIView?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destination = segue.destinationViewController as? Navigation {
            destination.rootController = self
        }
    }
    
    func openItem(navigationItem: NavigationItem) {
        let flowController = flowControllerFor(navigationItem)
        presentWith(flowController)
    }
    
    func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = UINavigationController()
        var flowController : FlowController
        
        switch navigationItem {
            
        case .Home: flowController = HomeFlowController(navigationController: navController)
        case .Discover: flowController = DiscoverFlowController(navigationController: navController)
        case .Shout: flowController = ShoutFlowController(navigationController: navController)
        case .Chats: flowController = ChatsFlowController(navigationController: navController)
        case .Profile: flowController = ProfileFlowController(navigationController: navController)
        default: flowController = HomeFlowController(navigationController: navController)
            
        }
        
        return flowController
    }
    
    func presentWith(flowController: FlowController) {
        contentContainer?.subviews[0].removeFromSuperview()
        
        let navigationController = flowController.navigationController
        
        navigationController.willMoveToParentViewController(self)
        
        let newContentView = navigationController.view!
        contentContainer?.addSubview(newContentView)
        
        self.addChildViewController(navigationController)
        
        navigationController.didMoveToParentViewController(self)
        
    }
    
}
