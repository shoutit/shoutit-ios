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
    
    var viewControllers = [NavigationItem: UIViewController]()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destination = segue.destinationViewController as? Navigation {
            destination.rootController = self
        }
    }
    
    // MARK: Side Menu
    
    @IBAction func toggleMenu() {
        
    }
    
    // MARK: Content Managing
    
    func openItem(navigationItem: NavigationItem) {
        let loadedController = viewControllers[navigationItem]
        
        if (loadedController != nil) {
            changeContentTo(loadedController!)
            return
        }
        
        let flowController = flowControllerFor(navigationItem)
        
        presentWith(flowController)
        
        viewControllers[navigationItem] = flowController.navigationController
        
    }
    
    func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = SHNavigationViewController()
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
        
        if let navigationController : UINavigationController = flowController.navigationController {
            changeContentTo(navigationController)
            return
        } else {
            fatalError("Flow Controller did not return UIViewController")
        }
    }
    
    func changeContentTo(controller: UIViewController) {
        contentContainer?.subviews[0].removeFromSuperview()
        
        controller.willMoveToParentViewController(self)
        
        let newContentView = controller.view!
        contentContainer?.addSubview(newContentView)
        
        self.addChildViewController(controller)
        
        controller.didMoveToParentViewController(self)
    }
    
}
