//
//  SHProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHProfileCollectionViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, SHHeaderProfileReusableViewDelegate {

    private let viewController: SHProfileCollectionViewController
    private var userShouts = [SHShout]()
    private let shApiShout = SHApiShoutService()
    
    required init(viewController: SHProfileCollectionViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let username = self.viewController.user?.username {
            self.loadShoutStreamForUser(username)
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    // replyToAction
    func replyToAction() {
        let messageViewController = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMESSAGES) as! SHMessagesViewController
        messageViewController.isFromShout = true
        messageViewController.shout = nil
        messageViewController.title = self.viewController.user?.name
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromTop
        self.viewController.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.viewController.hidesBottomBarWhenPushed = true
        self.viewController.navigationController?.pushViewController(messageViewController, animated: false)
        self.viewController.hidesBottomBarWhenPushed = false
    }
    
    //loadShoutsForUser
    func loadShoutStreamForUser (username: String) {
        let currentPage = 1
        shApiShout.loadShoutStreamForUser(username, page: currentPage, cacheResponse: { (shShoutMeta) -> Void in
            self.updateUIForShouts(shShoutMeta)
            }) { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.updateUIForShouts(result)
                case .Failure(let error):
                    log.error("Error getting user Shouts \(error.localizedDescription)")
                }
        }
    }
    
    // collectionView
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        if(kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.CollectionReusableView.SHHeaderProfileReusableView, forIndexPath: indexPath) as! SHHeaderProfileReusableView
            if let user = self.viewController.user {
                headerView.setupViewForUser(user)
            }
            headerView.delegate = self
            reusableview = headerView
        }
       return reusableview
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userShouts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHShoutSquareCollectionViewCell, forIndexPath: indexPath) as! SHShoutSquareCollectionViewCell
        cell.setShout(self.userShouts[indexPath.item])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as! SHShoutDetailTableViewController
        detailView.title = self.userShouts[indexPath.row].title
        if let shoutId = self.userShouts[indexPath.row].id {
            detailView.getShoutDetails(shoutId)
        }
        self.viewController.navigationController?.pushViewController(detailView, animated: true)
    }
    
    //Mark SHHeaderProfileReusableViewDelegate
    func didPressListenersButton(button: UIButton) {
//        SHUserListTableViewController* listViewController = [SHNavigator viewControllerFromStoryboard:@"ProfileStoryboard" withViewControllerId:@"SHUserListTableViewController"];
//        listViewController.user = self.user;
//        listViewController.title = NSLocalizedString( @"Listeners",  @"Listeners");
//        [listViewController requestUsersForUser:self.user withParam:@"listeners" type:nil];
//        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    func didPressListeningButton(button: UIButton) {
//        SHUserListTableViewController* listViewController = [SHNavigator viewControllerFromStoryboard:@"ProfileStoryboard" withViewControllerId:@"SHUserListTableViewController"];
//        listViewController.user = self.user;
//        listViewController.title = NSLocalizedString(@"Listening", @"Listening");
//        [listViewController requestUsersForUser:self.user withParam:@"listening" type:@"users"];
//        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    func didPressTagsButton(button: UIButton) {
//        SHUserListTableViewController* listViewController = [SHNavigator viewControllerFromStoryboard:@"ProfileStoryboard" withViewControllerId:@"SHUserListTableViewController"];
//        listViewController.user = self.user;
//        listViewController.title = NSLocalizedString(@"Listening", @"Listening");
//        [listViewController requestUsersForUser:self.user withParam:@"listening" type:@"tags"];
//        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    func didPressCvShortcutButtonButton(button: UIButton) {
//        UIViewController *vc =self.navigationController.navigationController.viewControllers[1];
//        if([vc isKindOfClass:[SHSwipeTabbarViewController class]])
//        {
//            [[((SHSwipeTabbarViewController*)vc) swipeController]setSelectedIndex:0 animated:YES];
//            UINavigationController* nc = [((SHSwipeTabbarViewController*)vc) swipeController].viewControllers[0];
//            UIViewController *vcre = nc.viewControllers[0];
//            if([vcre isKindOfClass:[SHCreateShoutTableViewController class]])
//            {
//                [((SHCreateShoutTableViewController*)vcre) setupViewForStandard:NO];
//            }
//            
//        }
    }
    
    // Private
    func updateUIForShouts(shShoutMeta: SHShoutMeta) {
        self.userShouts = shShoutMeta.results
        self.viewController.collectionView?.reloadData()
    }
    

}
