//
//  SHTagProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTagProfileTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let viewController: SHTagProfileTableViewController
    
    required init(viewController: SHTagProfileTableViewController) {
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
    
    func listenAction() {
        
    }
    
    func listeningAction() {
//        SHTagListenersTableViewController* listViewController = [SHNavigator viewControllerFromStoryboard:@"TagStoryboard" withViewControllerId:@"SHTagListenersTableViewController"];
//        [listViewController requestUsersForTag:self.model.tag];
//        [self.navigationController pushViewController:listViewController animated:YES]
        
    }
    
    // TableView Datasource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Shouts", comment: "Shouts")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as! SHShoutTableViewCell
//        SHShout* shout = self.fetchedResultsController[indexPath.row];
//        
//        [cell setShout:shout];
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL)
//        detailView.title = [self.fetchedResultsController[indexPath.row] title];
//        [detailView getDetailShouts:self.fetchedResultsController[indexPath.row]];
        self.viewController.navigationController?.pushViewController(detailView, animated: true)
    }
    
    
    
}
