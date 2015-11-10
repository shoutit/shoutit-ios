//
//  SHLocationGetterViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 09/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLocationGetterViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {
    
    private var viewController: SHLocationGetterViewController
    
    required init(viewController: SHLocationGetterViewController) {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

}
