//
//  SHShoutPickerTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutPickerTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let viewController: SHShoutPickerTableViewController
    private var shouts = [SHShout]()
    private var user: SHUser?
    private var shApiShout = SHApiShoutService()
    
    required init(viewController: SHShoutPickerTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        requestSelfUserShouts()
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
    
    func requestSelfUserShouts () {
        self.shouts.removeAll()
        self.user = SHOauthToken.getFromCache()?.user
        if let username = self.user?.username {
            shApiShout.loadShoutStreamForUser(username, page: 1, cacheResponse: { (shShoutMeta) -> Void in
                self.updateUI(shShoutMeta)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error getting shouts \(error.localizedDescription)")
                    }
            }
        }
    }
    
    // tableview datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shouts.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Shouts"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as! SHShoutTableViewCell
        let shout = self.shouts[indexPath.row]
        cell.setShout(shout)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewController.delegate?.didFinishSelect(self.shouts[indexPath.row])
        self.viewController.navigationController?.popViewControllerAnimated(true)
    }
    
    // Private
    
    private func updateUI(shShoutMeta: SHShoutMeta) {
        self.shouts = shShoutMeta.results
        self.viewController.tableView.reloadData()
    }
    
}
