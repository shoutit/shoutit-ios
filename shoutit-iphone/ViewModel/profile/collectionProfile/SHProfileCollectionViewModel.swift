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
    private let userShouts = [SHShout]()
    private let shApiShout = SHApiShoutService()
    
    required init(viewController: SHProfileCollectionViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
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
    
    //loadShoutsForUser
    func loadShoutStreamForUser (username: String) {
        let currentPage = 1
        shApiShout.loadShoutStreamForUser(username, page: currentPage, cacheResponse: { (shShoutMeta) -> Void in
            //
            }) { (response) -> Void in
                //
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHShoutSquareCollectionViewCell, forIndexPath: indexPath) as! SHShoutSquareCollectionViewCell
        //[cell setShout:self.fetchedResultsController[indexPath.item]];
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as! SHShoutDetailTableViewController
//        detailView.delegate = self;
//        detailView.title = [self.fetchedResultsController[indexPath.row] title];
//        [detailView getDetailShouts:self.fetchedResultsController[indexPath.row]];
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
    

}
