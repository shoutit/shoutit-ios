//
//  NotificationsTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import DZNEmptyDataSet

protocol NotificationsTableViewControllerFlowDelegate: class, CreateShoutDisplayable, AllShoutsDisplayable, CartDisplayable, SearchDisplayable, ShoutDisplayable, PageDisplayable, EditProfileDisplayable, ProfileDisplayable, NotificationsDisplayable {}

class NotificationsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    private let cellIdentifier = "NotificationsCellIdentifier"
    private let disposeBag = DisposeBag()
    private var messages : [Notification] = []
    
    weak var flowDelegate: NotificationsTableViewControllerFlowDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotifications()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(reloadNotifications), forControlEvents: .ValueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self

    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No notifications to show", comment: ""))
    }
    
    @IBAction func reloadNotifications() {
        APINotificationsService.requestNotifications().subscribeNext { [weak self] (messages) -> Void in
            self?.refreshControl?.endRefreshing()
            self?.messages = messages
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NotificationsTableViewCell

        let message =  messages[indexPath.row]
        
        cell.bindWithNotificationMessage(message)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message =  messages[indexPath.row]
        
        markMessageAsRead(message)
        openMessageObject(message)
    }
    
    @IBAction func moreAction() {
        
        let actionSheetController = UIAlertController(title: NSLocalizedString("More", comment: ""), message: nil, preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Mark all as read", comment: ""), style: .Destructive, handler: { (action) -> Void in
            self.markAllAsRead()
        }))
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Notification Settings", comment: ""), style: .Default, handler: { (action) -> Void in
            self.openNotificationSettings()
        }))
        
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) -> Void in
            
        }))
        
        self.navigationController?.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func markAllAsRead() {
        
        var readedNotifications : [Notification] = []
        
        messages.each { (notif) -> () in
            readedNotifications.append(notif.readCopy())
        }
        
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        
        APINotificationsService.markAllAsRead().subscribe(onNext: { [weak self] () -> Void in
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
            
            self?.messages = readedNotifications
            
            self?.tableView.reloadData()
        }, onError: { [weak self] (error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
            self?.tableView.reloadData()
        }, onCompleted: { () -> Void in
                
        }, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func markMessageAsRead(notification: Notification) {
        
        let notificationIdx = messages.indexOf(notification)
        
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        
        APINotificationsService.markNotificationAsRead(notification).subscribe(onNext: { [weak self] (noti) -> Void in
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
            
            if let idx = notificationIdx {
                self?.messages.removeAtIndex(idx)
                self?.messages.insert(noti, atIndex: idx)
            }
            
            self?.tableView.reloadData()
        }, onError: { [weak self] (error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
            self?.tableView.reloadData()
        }, onCompleted: { () -> Void in
                
        }, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func openMessageObject(notification: Notification) {
        if let profile = notification.object?.profile {
            self.flowDelegate?.showProfile(profile)
            return
        }
        
        if let shout = notification.object?.shout {
            self.flowDelegate?.showShout(shout)
            return
        }
        
    }
    
    func openNotificationSettings() {
        notImplemented()
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
}
