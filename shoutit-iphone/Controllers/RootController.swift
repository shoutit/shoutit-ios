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

class RootController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var contentContainer : UIView?
    
    var flowControllers = [NavigationItem: FlowController]()
    
    private var token: dispatch_once_t = 0
    private let disposeBag = DisposeBag()
    let presentMenuSegue = "presentMenuSegue"
    
    // MARK: Life Cycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().rx_notification(Constants.Notification.ToggleMenuNotification).subscribeNext { notification in
            self.toggleMenuAction()
        }.addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_once(&token) {
            self.openItem(.Home)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destination = segue.destinationViewController as? Navigation {
            destination.rootController = self
        }
        
        if segue.identifier == presentMenuSegue {
            segue.destinationViewController.modalPresentationStyle = .Custom
            segue.destinationViewController.transitioningDelegate = self
        }
    }
    
    // MARK: Side Menu
    
    @IBAction func toggleMenuAction() {
        self.performSegueWithIdentifier(presentMenuSegue, sender: nil)
    }
    
    // MARK: Content Managing
    
    func openItem(navigationItem: NavigationItem) {
        
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let loadedFlowController = flowControllers[navigationItem] {
            changeContentTo(loadedFlowController.navigationController)
            return
        }
        
        let flowController = flowControllerFor(navigationItem)
        
        presentWith(flowController)
        
        flowControllers[navigationItem] = flowController
        
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
        case .Settings: flowController = SettingsFlowController(navigationController: navController)
        case .Help: flowController = HelpFlowController(navigationController: navController)
        case .InviteFriends: flowController = InviteFriendsFlowController(navigationController: navController)
        case .Location: flowController = LocationFlowController(navigationController: navController)
        default: flowController = HomeFlowController(navigationController: navController)
            
        }
        
        if flowController.requiresLoggedInUser() && !Account.sharedInstance.isUserLoggedIn {
            let navigationController = LoginNavigationViewController()
            
            let loginFlowController = LoginFlowController(navigationController: navigationController, skipIntro: true)
            
            return loginFlowController
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuDismissAnimationController()
    }
    
}

extension RootController: ApplicationMainViewControllerRootObject {}
