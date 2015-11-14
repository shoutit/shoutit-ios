//
//  SHStreamTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHStreamTableViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    private var viewController: SHStreamTableViewController
    private var fetchedResultsController = []
    private var selectedSegment: Int?
    private var searchBar = UISearchBar()
    
    required init(viewController: SHStreamTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.searchBar = UISearchBar(frame: CGRectMake(0, 20, self.viewController.view.frame.size.width, 44))
        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        self.viewController.navigationController!.view.insertSubview(self.searchBar, belowSubview: (self.viewController.navigationController?.navigationBar)!)
        self.showSearchBar(self.viewController.tableView)
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
    
    
    
//
//    - (void)showSearchBar:(UIScrollView*)sender
//    {
//    CGPoint currentPoint = sender.contentOffset;
//    float yMin = self.navigationController.navigationBar.frame.origin.y;
//    float yMax = yMin + self.navigationController.navigationBar.frame.size.height;
//    if(self.searchBar.frame.origin.y < yMax)
//    {
//    [UIView animateWithDuration:0.2 animations:
//    ^{
//    self.searchBar.center = CGPointMake(self.searchBar.center.x, self.searchBar.frame.size.height/2 + yMax );
//    if (currentPoint.y < 0)
//    {
//    CGPoint point = CGPointMake(currentPoint.x, -44);
//    [self.tableView setContentOffset:point];
//    
//    }
//    [self.tableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
//    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
//    
//    //self.searchBar.frame = frame;
//    }];
//    }
//    }
    
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
       return self.fetchedResultsController.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


}
