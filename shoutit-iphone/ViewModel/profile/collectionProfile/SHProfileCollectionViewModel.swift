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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didUpdateUser:"), name:"DidUpdateUser", object: nil)
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
    
    func pullToRefresh() {
        if let username = self.viewController.user?.username {
            self.loadShoutStreamForUser(username)
        }
    }
    
    func destroy() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didUpdateUser (notification: NSNotification) {
        guard let _ = notification.object else {
            return
        }
        if let user = notification.object as? SHUser, let username = user.username {
            self.viewController.user = user
            self.loadShoutStreamForUser(username)
           // self.viewController.collectionView?.reloadData()
        }
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
                self.viewController.collectionView?.pullToRefreshView.stopAnimating()
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
        var reusableview: UICollectionReusableView?
        if(kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.CollectionReusableView.SHHeaderProfileReusableView, forIndexPath: indexPath) as! SHHeaderProfileReusableView
            
            if let user = self.viewController.user {
                headerView.setupViewForUser(user, viewController: self.viewController)
                headerView.setNeedsDisplay()
            }
            headerView.delegate = self
            reusableview = headerView
            //collectionView.layoutIfNeeded()
        }
       return reusableview!
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
        let listViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHUSERLIST) as! SHUserListTableViewController
        listViewController.user = self.viewController.user
        listViewController.title = NSLocalizedString("Listeners", comment: "Listeners")
        if let user = self.viewController.user {
            listViewController.requestUsersAndTags(user, param: "listeners", type: "")
        }
        self.viewController.navigationController?.pushViewController(listViewController, animated: true)
    }
    
    func didPressListeningButton(button: UIButton) {
        let listViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHUSERLIST) as! SHUserListTableViewController
        listViewController.user = self.viewController.user
        listViewController.title = NSLocalizedString("Listening", comment: "Listening")
        if let user = self.viewController.user {
            listViewController.requestUsersAndTags(user, param: "listening", type: "users")
        }
        self.viewController.navigationController?.pushViewController(listViewController, animated: true)
    }
    
    func didPressTagsButton(button: UIButton) {
        let listViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHUSERLIST) as! SHUserListTableViewController
        listViewController.user = self.viewController.user
        listViewController.title = NSLocalizedString("Listening", comment: "Listening")
        if let user = self.viewController.user {
            listViewController.requestUsersAndTags(user, param: "listening", type: "tags")
        }
        self.viewController.navigationController?.pushViewController(listViewController, animated: true)
    }
    
    func didPressCvShortcutButtonButton(button: UIButton) {
        let tabVC = SHTabViewController()
        tabVC.selectedIndex = 0
        self.viewController.presentViewController(tabVC, animated: true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("ProfileVideoCV", object: false)
    }
    
    // Private
    func updateUIForShouts(shShoutMeta: SHShoutMeta) {
        self.userShouts = shShoutMeta.results
        self.viewController.collectionView?.reloadData()
       // self.viewController.collectionView?.layoutIfNeeded()
    }
    
    
}
