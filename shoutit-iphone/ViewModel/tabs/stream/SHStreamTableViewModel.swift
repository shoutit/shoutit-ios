//
//  SHStreamTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Foundation

class SHStreamTableViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    private var viewController: SHStreamTableViewController
    private var fetchedResultsController = []
    private var selectedSegment: Int?
    private var searchBar = UISearchBar()
    private var tap: UITapGestureRecognizer?
    
    required init(viewController: SHStreamTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.viewController.tabBarItem.title = NSLocalizedString("Stream", comment: "Stream")
        // Navigation Setup
        self.viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.tap = UITapGestureRecognizer(target: self, action: Selector("dismissSearchKeyboard:"))
        self.tap?.numberOfTapsRequired = 1
        
        self.viewController.tableView.scrollsToTop = true
        let mapB = UIBarButtonItem(image: UIImage(named: "mapButton"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("switchToMapView:"))
        self.viewController.navigationItem.rightBarButtonItem = mapB
        let loc = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("selectLocation:"))
        self.viewController.navigationItem.leftBarButtonItem = loc
        self.viewController.edgesForExtendedLayout = UIRectEdge.None
        setupNavigationBar()
        
        // SearchBar
        self.searchBar = UISearchBar(frame: CGRectMake(0, 20, self.viewController.view.frame.size.width, 44))
        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        self.viewController.navigationController!.view.insertSubview(self.searchBar, belowSubview: (self.viewController.navigationController?.navigationBar)!)
        self.showSearchBar(self.viewController.tableView)
        
        // Get Latest Shouts
        self.selectedSegment = 0
        self.getLatestShouts()
        self.selectedSegment = 1
        self.getLatestShouts()
        self.selectedSegment = 2
        self.getLatestShouts()
        self.selectedSegment = 0

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
    
    func dismissSearchKeyboard(sender: AnyObject) {
        if (self.searchBar.isFirstResponder()) {
            if let tap = self.tap {
               self.viewController.tableView.removeGestureRecognizer(tap)
            }
            self.searchBar.resignFirstResponder()
        }
    }
    
    func showSearchBar(sender: UIScrollView) {
        let currentPoint: CGPoint = sender.contentOffset
        if let navBar = self.viewController.navigationController?.navigationBar {
            let yMin = navBar.frame.origin.y
            let yMax = yMin + navBar.frame.size.height
            if (self.searchBar.frame.origin.y < yMax) {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.searchBar.center = CGPointMake(self.searchBar.center.x, self.searchBar.frame.size.height/2 + yMax)
                    if(currentPoint.y < 0) {
                        let point: CGPoint = CGPointMake(currentPoint.x, -44)
                        self.viewController.tableView.setContentOffset(point, animated: true)
                        self.viewController.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
                        self.viewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0)
                    }
                })
            }
        }
    }
    
    func setupNavigationBar() {
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = self.viewController.title
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame: CGRectMake(0, 22, 0, 0))
        subTitleLabel.textAlignment = NSTextAlignment.Center
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        if let location = SHAddress.getUserOrDeviceLocation() {
            subTitleLabel.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
            subTitleLabel.sizeToFit()
        }
        let twoLineTitleView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30))
        twoLineTitleView.addSubview(titleLabel)
        twoLineTitleView.addSubview(subTitleLabel)
        let widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width
        if(widthDiff > 0) {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subTitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subTitleLabel.frame =  CGRectIntegral(frame)
        }
        self.viewController.navigationItem.titleView =  twoLineTitleView
    }
    
    func hideSearchBar(sender: UIScrollView) {
        if let navBar = self.viewController.navigationController?.navigationBar {
            let yMin = navBar.frame.origin.y
            let yMax = yMin + navBar.frame.size.height
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.searchBar.center = CGPointMake(self.searchBar.center.x, -self.searchBar.frame.size.height/2.0 + yMax)
                self.viewController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.viewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            })
            
        }
    }
    
    func getLatestShouts() {
        
    }
    
    func switchToMapView(sender: AnyObject) {
//        -(void)switchToMapView:(id)sender
//        {
//            SHStreamMapViewController *mapViewController = [SHNavigator viewControllerFromStoryboard:@"StreamStoryboard" withViewControllerId:@"SHStreamMapViewController"];
//            
//            mapViewController.model.filter = self.shoutModel.filter;
//            [UIView beginAnimations:@"View Flip" context:nil];
//            [UIView setAnimationDuration:0.50];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
//            [self.navigationController pushViewController:mapViewController animated:YES];
//            [UIView commitAnimations];
//        }
    }
    
    func selectLocation(sender: AnyObject) {
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.filterViewController];
//        // [navController.navigationBar setBarTintColor:[UIColor colorWithHex:@"#99c93b"]];
//        //navController.navigationBar.tintColor = [UIColor whiteColor];
//        [self presentViewController:navController animated:YES completion:nil];
    }
    
    
    // tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.selectedSegment == 0) {
            return 100
        } else if (self.selectedSegment == 1) {
            return 348
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    deinit {
        self.tap = nil
    }


}
