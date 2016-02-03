//
//  RootController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RootController: UIViewController {
        
    @IBOutlet weak var contentContainer : UIView?
    
    var viewControllers = [NavigationItem: UIViewController]()
    
    let disposeBag = DisposeBag()
    
    // MARK: Life Cycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().rx_notification(Constants.Notification.ToggleMenuNotification).subscribeNext { notification in
            self.toggleMenuAction()
        }.addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        openItem(.Home)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destination = segue.destinationViewController as? Navigation {
            destination.rootController = self
        }
    }
    
    // MARK: Side Menu
    
    @IBAction func toggleMenuAction() {
        self.performSegueWithIdentifier("presentMenuSegue", sender: nil)
    }
    
    // MARK: Content Managing
    
    func openItem(navigationItem: NavigationItem) {
        
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let loadedController = viewControllers[navigationItem] {
            changeContentTo(loadedController)
            return
        }
        
        let flowController = flowControllerFor(navigationItem)
        
        presentWith(flowController)
        
        viewControllers[navigationItem] = flowController.navigationController
        
    }
    
    func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = SHNavigationViewController()
        let flowController : FlowController
        
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
    
    func removeCurrentContent() {
        if let currentContent = contentContainer?.subviews[0] {
            currentContent.removeFromSuperview()
        }
        
        self.childViewControllers.each { child in
            child.willMoveToParentViewController(nil)
            child.removeFromParentViewController()
        }
    }
    
    func changeContentTo(controller: UIViewController) {
        
        removeCurrentContent()
        
        controller.willMoveToParentViewController(self)
        
        contentContainer?.addSubview(controller.view!)
        
        self.addChildViewController(controller)
        
        controller.didMoveToParentViewController(self)
    }
    
}

extension RootController: ApplicationMainViewControllerRootObject {}
