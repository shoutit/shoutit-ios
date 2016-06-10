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

class NotificationsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let cellIdentifier = "NotificationsCellIdentifier"
    private let disposeBag = DisposeBag()
    private var pusherBag : DisposeBag?
    private var messages : [Notification] = []
    
    var loading : Bool = false {
        didSet {
            if loading {
                self.activityIndicator.startAnimating()
                self.activityIndicator.hidden = false
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
        }
    }
    
    weak var flowDelegate: FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotifications()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(reloadNotifications), forControlEvents: .ValueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForNotificationUpdates()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        pusherBag = nil
        
        self.refreshControl?.endRefreshing()
    }
    
    func registerForNotificationUpdates() {
        pusherBag = DisposeBag()
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribeNext { [weak self] (event) in
            if event.eventType() == .NewNotification {
                if let notification : Notification = event.object() {
                    self?.insertMessage(notification)
                }
            }
        }.addDisposableTo(pusherBag!)
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No notifications to show", comment: ""))
    }
    
    @IBAction func reloadNotifications() {
        loading = true
        
        APINotificationsService.requestNotificationsBefore(nil).subscribeNext { [weak self] (messages) -> Void in
            self?.loading = false
            self?.refreshControl?.endRefreshing()
            self?.appendMessages(messages)
        }.addDisposableTo(disposeBag)
    }
    
    func loadNextPage() {
        if loading {
            return
        }
        
        guard let lastNotification = messages.last else {
            return
        }
        
        loading = true
        
        APINotificationsService.requestNotificationsBefore(lastNotification.createdAt).subscribe { [weak self] (event) in
            switch event {
            case .Next(let messages):
                
                if messages.count > 0 {
                    self?.loading = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.hidden = true
                }
                
                self?.appendMessages(messages)
            case .Error:
                self?.loading = false
            default:
                break;
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func appendMessages(messages: [Notification]) {
        self.messages.appendContentsOf(messages)
        self.messages = self.messages.unique()
        self.tableView.reloadData()
    }
    
    private func insertMessage(message: Notification) {
        
        self.tableView.beginUpdates()
        
        self.messages.insert(message, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        self.tableView.endUpdates()
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
        
        APINotificationsService.markNotificationAsRead(notification).subscribe(onNext: {
            MBProgressHUD.hideAllHUDsForView(self.tableView, animated: true)
            
            if let idx = notificationIdx {
                
                let readedCopy = notification.readCopy()
                
                self.messages.removeAtIndex(idx)
                self.messages.insert(readedCopy, atIndex: idx)
            }
            
            self.tableView.reloadData()
        }, onError: { [weak self] (error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
            self?.showError(error)
            self?.tableView.reloadData()
        }, onCompleted: { () -> Void in
                
        }, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func openMessageObject(notification: Notification) {
        guard let path = notification.appPath, url = NSURL(string: path) else { return }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func openNotificationSettings() {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(settingsURL)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            loadNextPage()
        }
    }
}
