//
//  SHStreamTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Foundation

class SHStreamTableViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {
    
    
    private var viewController: SHStreamTableViewController
    
    required init(viewController: SHStreamTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.viewController.tabBarItem.title = NSLocalizedString("Stream", comment: "Stream")
        // Navigation Setup
        self.viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.viewController.tableView.scrollsToTop = true
        let mapB = UIBarButtonItem(image: UIImage(named: "mapButton"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("switchToMapView:"))
        self.viewController.navigationItem.rightBarButtonItem = mapB
        let loc = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("selectLocation:"))
        self.viewController.navigationItem.leftBarButtonItem = loc
        self.viewController.edgesForExtendedLayout = UIRectEdge.None
        setupNavigationBar()
        // Get Latest Shouts
        self.viewController.selectedSegment = 0
        getLatestShouts()
        self.viewController.selectedSegment = 1
        getLatestShouts()
        self.viewController.selectedSegment = 2
        getLatestShouts()
        self.viewController.selectedSegment = 0
        
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
    
    private func setupNavigationBar() {
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
    
    private func getLatestShouts() {
        self.viewController.searchQuery = nil
        self.viewController.searchBar.text = ""
        self.viewController.mode = "Search"
        self.viewController.searchBar.placeholder = self.viewController.mode
        self.viewController.loading = true
        // [self.loadMoreView showNoMoreContent]; 
        self.viewController.fetchedResultsController = []
        self.viewController.tableView.reloadData()
        if(self.viewController.selectedSegment == 0 || self.viewController.selectedSegment == 1) {
            if let location = SHAddress.getUserOrDeviceLocation(), let type = self.viewController.selectedSegment {
                self.viewController.shoutApi.refreshStreamForLocation(location, ofType: type)
            } else {
                self.viewController.isSearchMode = false
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    if let location = SHAddress.getUserOrDeviceLocation() {
                        self.viewController.tagsApi.refreshTopTagsForLocation(location)
                    }
                    
                })
            }
            
        }
        
    }
    
    private func switchToMapView(sender: AnyObject) {
        let mapViewController = Constants.ViewControllers.STREAM_MAP
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
    
    private func selectLocation(sender: AnyObject) {
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.filterViewController];
//        // [navController.navigationBar setBarTintColor:[UIColor colorWithHex:@"#99c93b"]];
//        //navController.navigationBar.tintColor = [UIColor whiteColor];
//        [self presentViewController:navController animated:YES completion:nil];
    }
    
    
    // tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let obj: AnyObject = self.viewController.fetchedResultsController[indexPath.row]
        if(obj.isKindOfClass(SHShout)) {
            let shout = obj as! SHShout
            if(self.viewController.selectedSegment == 1) {
                if(shout.videoUrl != "") {
                    if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHRequestVideoTableViewCell, forIndexPath: indexPath) as? SHRequestVideoTableViewCell {
                        cell.setShout(shout)
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHRequestImageTableViewCell, forIndexPath: indexPath) as? SHRequestImageTableViewCell {
                        cell.setShout(shout)
                        return cell
                    }
                }
            } else if (self.viewController.selectedSegment == 0) {
                if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as? SHShoutTableViewCell {
                    cell.setShout(shout)
                    return cell
                }
                
            }
        } else {
            
          //  let shTag = SHTag()
            
         //   SHTag* shTag = (SHTag*)obj;
            //            SHTopTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHTopTagTableViewCell" forIndexPath:indexPath];
            //            [cell setTagCell:shTag];
            //            return cell;
        }
        
//        id  obj = self.fetchedResultsController[indexPath.row];
//        if([obj isKindOfClass:[SHShout class]])
//        {
//            SHShout* shout = (SHShout*)obj;
//            if (self.selectedSegment == 1)
//            {
//                if(shout.video_url!=nil)
//                {
//                    SHRequestVideoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SHRequestVideoTableViewCell" forIndexPath:indexPath];
//                    [cell setShout:shout];
//                    
//                    
//                    return cell;
//                }else{
//                    SHRequestImageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SHRequestImageTableViewCell" forIndexPath:indexPath];
//                    [cell setShout:shout];
//                    return cell;
//                }
//            }
//            else if(self.selectedSegment == 0)
//            {
//                SHShoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHShoutTableViewCell" forIndexPath:indexPath];
//                [cell setShout:shout];
//                return cell;
//            }
//        }else{
//            SHTag* shTag = (SHTag*)obj;
//            SHTopTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHTopTagTableViewCell" forIndexPath:indexPath];
//            [cell setTagCell:shTag];
//            return cell;
//        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.viewController.selectedSegment == 0) {
            return 100
        } else if (self.viewController.selectedSegment == 1) {
            return 348
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.viewController.fetchedResultsController.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


}
