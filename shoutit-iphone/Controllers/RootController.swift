


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
    
    private let defaultTabBarHeight: CGFloat = 49
    
    @IBOutlet weak var contentContainer : UIView?
    @IBOutlet weak var tabbarHeightConstraint: NSLayoutConstraint!
    
    var flowControllers = [NavigationItem: FlowController]()
    var currentControllerConstraints: [NSLayoutConstraint] = []
    private var loginFlowController: LoginFlowController?
    
    private var token: dispatch_once_t = 0
    private let disposeBag = DisposeBag()
    let presentMenuSegue = "presentMenuSegue"
    
    var currentNavigationItem : NavigationItem? {
        didSet {
            self.tabbarController?.selectedNavigationItem = currentNavigationItem
        }
    }
    var tabbarController : TabbarController?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter()
            .rx_notification(Constants.Notification.UserDidLogoutNotification)
            .subscribeNext { [unowned self] notification in
                self.openItem(.Home)
            }
            .addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter()
            .rx_notification(Constants.Notification.ToggleMenuNotification)
            .subscribeNext { notification in
                self.toggleMenuAction()
            }
            .addDisposableTo(disposeBag)
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
            destination.selectedNavigationItem = self.currentNavigationItem
        }
        
        if let destination = segue.destinationViewController as? TabbarController {
            self.tabbarController = destination
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
    
    func invalidateControllersCache() {
        flowControllers.removeAll()
    }
    
    func openItem(navigationItem: NavigationItem) {
        
        // Woooot!
        // Create Shout Controller should be presented above root Controller, so skip flow controller logic
        if navigationItem == .Shout {
            showCreateShout()
            return
        }
        
        self.currentNavigationItem = navigationItem
        
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let flowControllerToShow: FlowController
        
        if let loadedFlowController = flowControllers[navigationItem] {
            flowControllerToShow = loadedFlowController
        } else {
            flowControllerToShow = flowControllerFor(navigationItem)
            flowControllers[navigationItem] = flowControllerToShow
        }
        
        if let locationFlowController = flowControllerToShow as? LocationFlowController {
            locationFlowController.finishedBlock = {[weak self](success, place) -> Void in
                self?.openItem(.Home)
            }

        }
        
        if flowControllerToShow.requiresLoggedInUser() && !Account.sharedInstance.isUserLoggedIn {
            let navigationController = LoginNavigationViewController()
            loginFlowController = LoginFlowController(navigationController: navigationController, skipIntro: true)
            loginFlowController?.loginFinishedBlock = {[weak self](success) -> Void in
                self?.invalidateControllersCache()
                self?.openItem(.Home)
            }
            presentWith(loginFlowController!)
            return
        }
        
        presentWith(flowControllerToShow)
    }
    
    func showCreateShout() {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let navController = SHNavigationViewController()
        let shoutsFlowController = ShoutFlowController(navigationController: navController)
        
        navController.modalPresentationStyle = .Custom
        navController.transitioningDelegate = self
        
        // present directly above current content
        self.presentViewController(shoutsFlowController.navigationController, animated: true, completion: nil)
    }
    
    func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = SHNavigationViewController()
        navController.willShowViewControllerPreferringTabBarHidden = {[unowned self] (hidden) in
            self.tabbarHeightConstraint.constant = hidden ? 0 : self.defaultTabBarHeight
            self.view.layoutIfNeeded()
        }
        let flowController : FlowController
        
        switch navigationItem {
            
        case .Home: flowController          = HomeFlowController(navigationController: navController)
        case .Discover: flowController      = DiscoverFlowController(navigationController: navController)
        case .Shout: flowController         = ShoutFlowController(navigationController: navController)
        case .Chats: flowController         = ChatsFlowController(navigationController: navController)
        case .Profile: flowController       = ProfileFlowController(navigationController: navController)
        case .Settings: flowController      = SettingsFlowController(navigationController: navController)
        case .Help: flowController          = HelpFlowController(navigationController: navController)
        case .InviteFriends: flowController = InviteFriendsFlowController(navigationController: navController)
        case .Location: flowController      = LocationFlowController(navigationController: navController)
        case .Orders: flowController        = OrdersFlowController(navigationController: navController)
        case .Browse: flowController        = BrowseFlowController(navigationController: navController)
        default: flowController             = HomeFlowController(navigationController: navController)
            
        }
        
        return flowController
    }
    
    func presentWith(flowController: FlowController) {
        
        guard let navigationController : UINavigationController = flowController.navigationController else  {
            fatalError("Flow Controller did not return UIViewController")
        }
        
        changeContentTo(navigationController)
    }
    
    func removeCurrentContent() {
        
        contentContainer?.removeConstraints(currentControllerConstraints)
        
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
        let views = ["child" : controller.view!]
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        currentControllerConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[child]|", options: [], metrics: nil, views: views)
        currentControllerConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[child]|", options: [], metrics: nil, views: views)
        contentContainer?.addConstraints(currentControllerConstraints)
        
        self.addChildViewController(controller)
        
        controller.didMoveToParentViewController(self)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = presented as? MenuTableViewController {
           return MenuAnimationController()
        }
       
        return OverlayAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = dismissed as? MenuTableViewController {
            return MenuDismissAnimationController()
        }
        
        return OverlayDismissAnimationController()
    }
    
    @IBAction func unwindToRootController(segue: UIStoryboardSegue) {
    }
    
}

extension RootController: ApplicationMainViewControllerRootObject {}
