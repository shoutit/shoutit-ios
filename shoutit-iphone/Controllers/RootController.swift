


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
    
    private lazy var __once: () = {
            self.openItem(.Home)
        }()
    
    fileprivate let defaultTabBarHeight: CGFloat = 49
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var tabbarHeightConstraint: NSLayoutConstraint!
    
    var flowControllers = [NavigationItem: FlowController]()
    fileprivate var loginFlowController: LoginFlowController?
    
    fileprivate var token: Int = 0
    fileprivate let disposeBag = DisposeBag()
    fileprivate let presentMenuSegue = "presentMenuSegue"
    lazy var animationDelegate = RootControllerAnimationDelegate()
    
    var currentNavigationItem : NavigationItem? {
        willSet(newItem) {
            guard let newItem = newItem else {
                return
            }
            
            if currentNavigationItem == newItem {
                if let flow = flowControllers[newItem] {
                    flow.navigationController.popToRootViewController(animated: true)
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
            .subscribe(onNext: {_ in
                self.sh_invalidateControllersCache()
                self.openItem(.Home)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(openItemFromNotification), name: NSNotification.Name(rawValue: Constants.Notification.RootControllerShouldOpenNavigationItem), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkRateApp), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.RootControllerShouldOpenNavigationItem), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func checkRateApp() {
        if RateApp.sharedInstance().shouldEnjoyPrompt() {
            showRateApp()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = self.__once
        
        checkRateApp()
    }
    
    func showRateApp() {
        var currentItem : NavigationItem? = self.currentNavigationItem
        
        if currentItem == nil {
            currentItem = .Home
            self.openItem(.Home)
        }
        
        guard let currentFlowController = self.flowControllers[currentItem!] else {
            return
        }
        
        let rate = RateApp.sharedInstance()
        
        let alert = rate.promptEnjoyAlert({ [weak currentFlowController] (decision) in
            if decision == true {
                let alert = rate.promptRateAlert({ (rate) in })
                
                
                currentFlowController?.navigationController.present(alert, animated: true, completion: nil)
            } else {
                let alert = rate.promptFeedbackAlert({ (feedback) in
                    if feedback { UserVoice.presentContactUsForm(forParentViewController: currentFlowController?.navigationController) }
                })
                currentFlowController?.navigationController.present(alert, animated: true, completion: nil)
            }
            })
        
        currentFlowController.navigationController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Status bar
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return currentChildViewController
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Navigation {
            destination.rootController = self
            destination.selectedNavigationItem = self.currentNavigationItem
        }
        
        if let destination = segue.destination as? TabbarController {
            self.tabbarController = destination
        } else if let controller = segue.destination as? MenuTableViewController {
            controller.viewModel = MenuViewModel(loginState: Account.sharedInstance.loginState)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = animationDelegate as! UIViewControllerTransitioningDelegate
            
        }
    }
    
    // MARK: - IB
    
    @IBAction func toggleMenuAction() {
        self.performSegue(withIdentifier: presentMenuSegue, sender: nil)
    }
    
    @IBAction func unwindToRootController(_ segue: UIStoryboardSegue) {}
    
    // MARK: - Actions
    
    func openItemFromNotification(_ notification: Foundation.Notification) {
        if let itemString = notification.userInfo?["item"] as? String, let item = NavigationItem(rawValue: itemString) {
            openItem(item)
        }
    }
    
    func openItem(_ navigationItem: NavigationItem, deepLink: DPLDeepLink? = nil) {
        
        var item = navigationItem
        
        if navigationItem == .Conversation || navigationItem == .Shout || (navigationItem == .Profile && deepLink != nil) || navigationItem == .CreditsTransations || navigationItem == .Search || navigationItem == .StaticPage {
            self.showOverExistingFlowController(navigationItem, deepLink: deepLink)
            return
        }
        
        if let presentedNavigation = self.presentedViewController as? UINavigationController, let presentedStaticPage = presentedNavigation.visibleViewController as? StaticPageViewController {
            presentedStaticPage.dismiss(animated: true, completion: { [weak self] in
                    self?.openItem(navigationItem, deepLink: deepLink)
                })
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
            presentedMenu.dismiss(animated: true, completion: nil)
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
    
    func showOverExistingFlowController(_ navigationItem: NavigationItem, deepLink: DPLDeepLink?) {
        if self.presentedViewController != nil {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
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
        case .StaticPage:
            
            
            guard let url = deepLink?.url else { return }
            
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            let queryItems = urlComponents?.queryItems
            
            guard let path = queryItems?.filter({$0.name == "page"}).first, let urlPath = path.value, let fullURL = URL(string: urlPath) else { return }
            
            let staticComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
                
            guard let titleComponent = staticComponents?.queryItems?.filter({$0.name == "title"}).first, let destinationURL = try? staticComponents?.asURL(), let title = titleComponent.value else { return }
            
            currentFlowController.showStaticPage(destinationURL!, title: title)
        case .Search:
            currentFlowController.showSearchInContext(.general)
        default:
            break
        }
    }
    
    func cachedFlowControllerForNavigationItem(_ navigationItem: NavigationItem) -> FlowController? {
        return flowControllers[navigationItem]
    }
}

// MARK: - Routing
extension RootController {
    func routeToNavigationItem(_ navigationItem: NavigationItem, withDeeplink deeplink: DPLDeepLink) {
        self.openItem(navigationItem, deepLink: deeplink)
    }
}

// MARK: - Notifications

extension RootController {
    
    fileprivate func registerForNotifications() {
        
        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Constants.Notification.UserDidLogoutNotification))
            .subscribe(onNext: { [unowned self] notification in
                self.openItem(.Home)
            })
            .addDisposableTo(disposeBag)
        
        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Constants.Notification.ToggleMenuNotification))
            .subscribe(onNext: { notification in
                self.toggleMenuAction()
            })
            .addDisposableTo(disposeBag)
        
        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Constants.Notification.IncomingCallNotification))
            .subscribe(onNext: { notification in
                self.incomingCall(notification)
            })
            .addDisposableTo(disposeBag)
    }
    
    func incomingCall(_ notification: Foundation.Notification) {
        let invitation = notification.object as! TWCIncomingInvite
        
        let controller = Wireframe.incomingCallController()
        
        controller.invitation = invitation
        
        let media = TWCLocalMedia()
        
        controller.answerHandler = { (invitation) in
            invitation.accept(with: media, completion: { (conversation, error) in
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
        
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = animationDelegate as! UIViewControllerTransitioningDelegate
        
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: - Main logic

private extension RootController {
    
    func flowControllerFor(_ navigationItem: NavigationItem) -> FlowController {
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
        case .Bookmarks: flowController     = BookmarksFlowController(navigationController: navController)
        default: flowController             = HomeFlowController(navigationController: navController)
        }
        
        return flowController
    }
    
    func presentWith(_ flowController: FlowController) {
        
        guard let navigationController : UINavigationController = flowController.navigationController else  {
            fatalError("Flow Controller did not return UIViewController")
        }
        
        changeContentTo(navigationController)
    }
    
    func presentFlowControllerModally(_ flowController: FlowController) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismiss(animated: true, completion: nil)
        }
        
        if let navController = flowController.navigationController as? SHNavigationViewController {
            navController.ignoreToggleMenu = true
        }
        
        self.present(flowController.navigationController, animated: true, completion: nil)
    }
    
    func sh_invalidateControllersCache() {
        flowControllers.removeAll()
    }
}

// MARK: - Login

private extension RootController {
    
    func promptUserForLogin(_ destinationNavigationItem: NavigationItem, deepLink : DPLDeepLink? = nil) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismiss(animated: true, completion: nil)
        }
        
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController, skipIntro: true)
        loginFlowController?.loginFinishedBlock = {[weak self](success) -> Void in
            self?.sh_invalidateControllersCache()
            self?.loginFlowController?.navigationController.dismiss(animated: true, completion: nil)
            self?.openItem(destinationNavigationItem, deepLink: deepLink)
        }
        
        self.present(navigationController, animated: true, completion: nil)
    }
}

private extension RootController {
    
    func showHelp() {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismiss(animated: true, completion: nil)
        }
        UserVoice.presentInterface(forParentViewController: self.parent!)
    }
    
    func showCreateShout(_ deepLink: DPLDeepLink? = nil) {
        if let presentedMenu = self.presentedViewController as? MenuTableViewController {
            presentedMenu.dismiss(animated: true, completion: nil)
        }
        
        if !Account.sharedInstance.isUserLoggedIn {
            promptUserForLogin(.CreateShout)
            return
        }
        
        let navController = SHNavigationViewController()
        let shoutsFlowController = ShoutFlowController(navigationController: navController)
        
        shoutsFlowController.deepLink = deepLink
        shoutsFlowController.handleDeeplink(deepLink)
        
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = animationDelegate
        
        // present directly above current content
        self.present(shoutsFlowController.navigationController, animated: true, completion: nil)
    }
}

extension RootController: ApplicationMainViewControllerRootObject {}
extension RootController {
    func showVideoConversation(_ conversation: TWCConversation, media: TWCLocalMedia, invitation: TWCIncomingInvite) -> Void {
        let controller = Wireframe.videoCallController()
        controller.viewModel = VideoCallViewModel(conversation: conversation, localMedia: media, invitation: invitation)
        self.present(controller, animated: true, completion: nil)
    }
}
