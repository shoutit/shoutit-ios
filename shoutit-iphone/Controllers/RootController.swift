


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
import ShoutitKit

final class RootController: UIViewController, ContainerController {
    
    private let defaultTabBarHeight: CGFloat = 49
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var tabbarHeightConstraint: NSLayoutConstraint!
    
    var flowControllers = [NavigationItem: FlowController]()
    private var loginFlowController: LoginFlowController?
    
    private var token: dispatch_once_t = 0
    private let disposeBag = DisposeBag()
    private let presentMenuSegue = "presentMenuSegue"
    
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
    weak var currentChildViewController: UIViewController?
    var currentControllerConstraints: [NSLayoutConstraint] = []
    var tabbarController : TabbarController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotifications()

        Account.sharedInstance
            .loginSubject
//            .distinctUntilChanged{(old, new) -> Bool in
//                if old == nil {
//                    return true
//                }
//                return false
//            }
            .observeOn(MainScheduler.instance)
            .subscribeNext {_ in
                self.sh_invalidateControllersCache()
                self.openItem(.Home)
            }
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(openItemFromNotification), name: Constants.Notification.RootControllerShouldOpenNavigationItem, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notification.RootControllerShouldOpenNavigationItem, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_once(&token) {
            self.openItem(.Home)
        }
    }
    
    // MARK: - Status bar
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return currentChildViewController
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Navigation
    
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
    
    // MARK: - IB
    
    @IBAction func toggleMenuAction() {
        self.performSegueWithIdentifier(presentMenuSegue, sender: nil)
    }
    
    @IBAction func unwindToRootController(segue: UIStoryboardSegue) {}
    
    // MARK: - Actions
    
    func openItemFromNotification(notification: NSNotification) {
        if let itemString = notification.userInfo?["item"] as? String, item = NavigationItem(rawValue: itemString) {
            openItem(item)
        }
    }
    
    func openItem(navigationItem: NavigationItem, deepLink: DPLDeepLink? = nil) {
        
        var item = navigationItem
        
        if navigationItem == .Conversation || navigationItem == .Shout || (navigationItem == .Profile && deepLink != nil) || navigationItem == .CreditsTransations {
            self.showOverExistingFlowController(navigationItem, deepLink: deepLink)
            return
        }
        
        if navigationItem == .PublicChats {
            item = .Chats
        }
        
        if navigationItem == .CreditsTransations {
            item = .Credits
        }
        
        if navigationItem == .Notifications {
            item = .Settings
        }
        
        // Woooot!
        // Create Shout Controller should be presented above root Controller, so skip flow controller logic
        if item == .CreateShout {
            showCreateShout(deepLink)
            return
        } else if item == .Help {
            showHelp()
            return
        }
        
        self.currentNavigationItem = item
        
        let flowControllerToShow: FlowController
        
        if let loadedFlowController = cachedFlowControllerForNavigationItem(item) {
            flowControllerToShow = loadedFlowController
        } else {
            flowControllerToShow = flowControllerFor(item)
            flowControllers[item] = flowControllerToShow
        }
        
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
            if let navigationController = flowControllerToShow.navigationController as? SHNavigationViewController {
                navigationController.adjustTabBarControllerForTopViewController()
            }
        }
        
        // Location Controller Should Be Presented Modally instead of within tabbar
        if let locationFlowController = flowControllerToShow as? LocationFlowController {
            
            locationFlowController.finishedBlock = { (success, place) -> Void in
                if let controller = locationFlowController.navigationController.visibleViewController as? ChangeLocationTableViewController {
                    controller.dismiss()
                }
            }
            
            locationFlowController.setShouldShowAutoUpdates(true)
            
            presentFlowControllerModally(locationFlowController)
            return
        }
        
        // Check if controller requires logged user
        if flowControllerToShow.requiresLoggedInUser() && !Account.sharedInstance.isUserLoggedIn {
            promptUserForLogin(navigationItem)
            return
        }
        
        flowControllerToShow.deepLink = deepLink
        flowControllerToShow.handleDeeplink(deepLink)
        
        presentWith(flowControllerToShow)
    }
    
    func showOverExistingFlowController(navigationItem: NavigationItem, deepLink: DPLDeepLink?) {
        if self.presentedViewController != nil {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        }
        
        var currentItem : NavigationItem? = self.currentNavigationItem
        
        if currentItem == nil {
            currentItem = .Home
            self.openItem(.Home)
        }
        
        guard let currentFlowController = self.flowControllers[currentItem!] else {
            return
        }
        
        switch navigationItem {
        case .Conversation:
            
            if !Account.sharedInstance.isUserLoggedIn {
                promptUserForLogin(navigationItem, deepLink: deepLink)
                return
            }
            
            guard let conversationId = deepLink?.queryParameters["id"] as? String else {
                return
            }
            
            currentFlowController.showConversationWithId(conversationId)
            
        case .Shout:
            guard let shoutId = deepLink?.queryParameters["id"] as? String else {
                return
            }
            
            currentFlowController.showShoutWithId(shoutId)
            
        case .Profile:
            guard let profileId = deepLink?.queryParameters["username"] as? String else {
                return
            }
            
            currentFlowController.showProfileWithId(profileId)
        
        case .CreditsTransations:
            if !Account.sharedInstance.isUserLoggedIn {
                promptUserForLogin(navigationItem, deepLink: deepLink)
                return
            }
            
            currentFlowController.showCreditTransactions()
        default:
            break
        }
    }
    
    func cachedFlowControllerForNavigationItem(navigationItem: NavigationItem) -> FlowController? {
        return flowControllers[navigationItem]
    }
}

extension RootController: UIViewControllerTransitioningDelegate {
    
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
}

// MARK: - Routing
extension RootController {
    func routeToNavigationItem(navigationItem: NavigationItem, withDeeplink deeplink: DPLDeepLink) {
        self.openItem(navigationItem, deepLink: deeplink)
    }
}

// MARK: - Notifications

extension RootController {
    
    private func registerForNotifications() {
        
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
                    self.showVideoConversation(conversation, media: media, invitation: invitation)
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
}

// MARK: - Main logic

private extension RootController {
    
    private func flowControllerFor(navigationItem: NavigationItem) -> FlowController {
        let navController = SHNavigationViewController()
        navController.willShowViewControllerPreferringTabBarHidden = {[unowned self, unowned navController] (hidden) in
            if navController.ignoreTabbarAppearance {
                return
            }
            
            self.tabbarHeightConstraint.constant = hidden ? 0 : self.defaultTabBarHeight
            self.view.layoutIfNeeded()
            self.view.setNeedsDisplay()
        }
        let flowController : FlowController
        
        switch navigationItem {
            
        case .Home: flowController          = HomeFlowController(navigationController: navController)
        case .Discover: flowController      = DiscoverFlowController(navigationController: navController)
        case .CreateShout: flowController   = ShoutFlowController(navigationController: navController)
        case .Chats: flowController         = ChatsFlowController(navigationController: navController)
        case .Profile: flowController       = ProfileFlowController(navigationController: navController)
        case .Settings: flowController      = SettingsFlowController(navigationController: navController)
        case .InviteFriends: flowController = InviteFriendsFlowController(navigationController: navController)
        case .Location: flowController      = LocationFlowController(navigationController: navController)
        case .Orders: flowController        = OrdersFlowController(navigationController: navController)
        case .Browse: flowController        = BrowseFlowController(navigationController: navController)
        case .Credits: flowController       = CreditsFlowController(navigationController: navController)
        case .Pages: flowController         = PagesFlowController(navigationController: navController)
        case .Admins: flowController        = AdminsFlowController(navigationController: navController)
        default: flowController             = HomeFlowController(navigationController: navController)
        }
        
        return flowController
    }
    
    private func presentWith(flowController: FlowController) {
        
        guard let navigationController : UINavigationController = flowController.navigationController else  {
            fatalError("Flow Controller did not return UIViewController")
        }
        
        changeContentTo(navigationController)
    }
    
    private func presentFlowControllerModally(flowController: FlowController) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let navController = flowController.navigationController as? SHNavigationViewController {
            navController.ignoreToggleMenu = true
        }
        
        self.presentViewController(flowController.navigationController, animated: true, completion: nil)
    }
    
    private func sh_invalidateControllersCache() {
        flowControllers.removeAll()
    }
}

// MARK: - Login

private extension RootController {
    
    private func promptUserForLogin(destinationNavigationItem: NavigationItem, deepLink : DPLDeepLink? = nil) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController, skipIntro: true)
        loginFlowController?.loginFinishedBlock = {[weak self](success) -> Void in
            self?.sh_invalidateControllersCache()
            self?.loginFlowController?.navigationController.dismissViewControllerAnimated(true, completion: nil)
            self?.openItem(destinationNavigationItem, deepLink: deepLink)
        }
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}

private extension RootController {
    
    private func showHelp() {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        UserVoice.presentUserVoiceInterfaceForParentViewController(self.parentViewController!)
    }
    
    private func showCreateShout(deepLink: DPLDeepLink? = nil) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if !Account.sharedInstance.isUserLoggedIn {
            promptUserForLogin(.CreateShout)
            return
        }
        
        let navController = SHNavigationViewController()
        let shoutsFlowController = ShoutFlowController(navigationController: navController)
        
        shoutsFlowController.deepLink = deepLink
        shoutsFlowController.handleDeeplink(deepLink)
        
        navController.modalPresentationStyle = .Custom
        navController.transitioningDelegate = self
        
        // present directly above current content
        self.presentViewController(shoutsFlowController.navigationController, animated: true, completion: nil)
    }
}

extension RootController: ApplicationMainViewControllerRootObject {}
extension RootController {
    func showVideoConversation(conversation: TWCConversation, media: TWCLocalMedia, invitation: TWCIncomingInvite) -> Void {
        let controller = Wireframe.videoCallController()
        controller.viewModel = VideoCallViewModel(conversation: conversation, localMedia: media, invitation: invitation)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
