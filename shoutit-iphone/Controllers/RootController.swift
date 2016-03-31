


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
        willSet(newItem) {
            guard let newItem = newItem else {
                return
            }
            
            if currentNavigationItem == newItem {
                if let flow = flowControllers[newItem] {
                    flow.navigationController.popToRootViewControllerAnimated(true)
                }
            }
        }
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
        
        NSNotificationCenter.defaultCenter()
            .rx_notification(Constants.Notification.IncomingCallNotification)
            .subscribeNext { notification in
                self.incomingCall(notification)
            }
            .addDisposableTo(disposeBag)
        
        Account.sharedInstance.loginSubject.subscribeNext {
            self.invalidateControllersCache()
            self.openItem(.Home)
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
    
    func incomingCall(notification: NSNotification) {
        let invitation = notification.object as! TWCIncomingInvite
        
        let controller = Wireframe.incomingCallController()
        
        controller.invitation = invitation
        
        let media = TWCLocalMedia()
        
        controller.answerHandler = { (invitation) in
            invitation.acceptWithLocalMedia(media, completion: { (conversation, error) in
                if let error = error {
                    debugPrint(error)
                    return
                }
                
                if let conversation = conversation {
                    self.showVideoConversation(conversation, media: media)
                }
            })
        }
        
        controller.discardHandler = { (invitation) in
            invitation.reject()
        }
        
        controller.modalPresentationStyle = .Custom
        controller.transitioningDelegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
        
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
        
        // Location Controller Should Be Presented Modally instead of within tabbar
        if let locationFlowController = flowControllerToShow as? LocationFlowController {
            
            locationFlowController.finishedBlock = { (success, place) -> Void in
                if let controller = locationFlowController.navigationController.visibleViewController as? ChangeLocationTableViewController {
                    controller.dismiss()
                }
            }
            
            presentFlowControllerModally(locationFlowController)
            return
        }
        
        // Check if controller requires logged user
        if flowControllerToShow.requiresLoggedInUser() && !Account.sharedInstance.isUserLoggedIn {
            promptUserForLogin(navigationItem)
            return
        }
        
        presentWith(flowControllerToShow)
    }
    
    func showCreateShout() {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if !Account.sharedInstance.isUserLoggedIn {
            promptUserForLogin(.Shout)
            return
        }
        
        let navController = SHNavigationViewController()
        let shoutsFlowController = ShoutFlowController(navigationController: navController)
        
        navController.modalPresentationStyle = .Custom
        navController.transitioningDelegate = self
        
        // present directly above current content
        self.presentViewController(shoutsFlowController.navigationController, animated: true, completion: nil)
    }
    
    func presentFlowControllerModally(flowController: FlowController) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let navController = flowController.navigationController as? SHNavigationViewController {
            navController.ignoreToggleMenu = true
        }
        
        self.presentViewController(flowController.navigationController, animated: true, completion: nil)
    }
    
    func promptUserForLogin(destinationNavigationItem: NavigationItem) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController, skipIntro: true)
        loginFlowController?.loginFinishedBlock = {[weak self](success) -> Void in
            self?.invalidateControllersCache()
            self?.loginFlowController?.navigationController.dismissViewControllerAnimated(true, completion: nil)
            self?.openItem(destinationNavigationItem)
        }
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = SHNavigationViewController()
        navController.willShowViewControllerPreferringTabBarHidden = {[unowned self] (hidden) in
            self.tabbarHeightConstraint.constant = hidden ? 0 : self.defaultTabBarHeight
            self.view.layoutIfNeeded()
            self.view.setNeedsDisplay()
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
extension RootController {
    func showVideoConversation(conversation: TWCConversation, media: TWCLocalMedia) -> Void {
        let controller = Wireframe.videoCallController()
        
        controller.conversation = conversation
        controller.localMedia = media
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
