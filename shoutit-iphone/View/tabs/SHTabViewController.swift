//
//  SHTabViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTabStyle()
        self.addTabs()
        self.updateCache()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Private
    private func getNavController(viewController: UIViewController) -> UINavigationController {
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.tabBarItem = viewController.tabBarItem
        navVC.title = viewController.title
        navVC.navigationBar.barTintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
        navVC.navigationBar.tintColor = UIColor.whiteColor()
        return navVC
    }
    
    private func addTabs() {
        // Setup Tabs
        let shoutListVC = UIStoryboard.getShoutList().instantiateViewControllerWithIdentifier(Constants.ViewControllers.ShoutList) 
        shoutListVC.tabBarItem.image = UIImage(named: "tabHome")
        shoutListVC.tabBarItem.title = "Home"
    
        let discoverVC = UIStoryboard.getShoutList().instantiateViewControllerWithIdentifier(Constants.ViewControllers.ShoutList) as! SHShoutListViewController
        discoverVC.type = ShoutListType.DISCOVER
        discoverVC.tabBarItem.image = UIImage(named: "tabDiscover")
        discoverVC.tabBarItem.title = "Discover"
       // let discoverVC = UIStoryboard.getDiscover().instantiateViewControllerWithIdentifier(Constants.ViewControllers.DISCOVER_VC)
        let createShoutVC = UIStoryboard.getCreateShout().instantiateViewControllerWithIdentifier(Constants.ViewControllers.CREATE_SHOUT)
        let conversationVC = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHCONVERSATIONSTABLE)
        let profileVC = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPROFILE) as! SHProfileCollectionViewController
        profileVC.user = SHOauthToken.getFromCache()?.user
        self.viewControllers = [
            getNavController(shoutListVC),
            getNavController(discoverVC),
            getNavController(createShoutVC),
            getNavController(conversationVC),
            getNavController(profileVC)
        ]
    }
    
    private func setTabStyle() {
        UITabBar.appearance().tintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
        
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        UITabBar.appearance().translucent = false
    }
    
    private func updateCache() {
        SHApiMiscService().getCategories({ (categories) -> Void in
            // Do Nothing
            }) { (response) -> Void in
                // Do Nothing
        }
        
        SHApiMiscService().getCurrencies({ (currencies) -> Void in
            // Do Nothing
            }) { (response) -> Void in
                // Do Nothing
        }
    }

}
