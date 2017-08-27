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
import ShoutitKit

class NotificationsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    fileprivate let cellIdentifier = "NotificationsCellIdentifier"
    fileprivate let disposeBag = DisposeBag()
    fileprivate var pusherBag : DisposeBag?
    fileprivate var messages : [ShoutitKit.Notification] = []
    
    var loading : Bool = false {
        didSet {
            if loading {
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    weak var flowDelegate: FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotifications()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(reloadNotifications), for: .valueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForNotificationUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pusherBag = nil
        
        self.refreshControl?.endRefreshing()
    }
    
    func registerForNotificationUpdates() {
        pusherBag = DisposeBag()
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribe(onNext: { [weak self] (event) in
            if event.eventType() == .NewNotification {
                if let notification : Notification = event.object() {
                    self?.insertMessage(notification)
                }
            }
        }).addDisposableTo(pusherBag!)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No notifications to show", comment: "Notifications Placeholder"))
    }
    
    @IBAction func reloadNotifications() {
        loading = true
        
        APINotificationsService.requestNotificationsBefore(nil).subscribe(onNext: { [weak self] (messages) -> Void in
            self?.loading = false
            self?.refreshControl?.endRefreshing()
            self?.appendMessages(messages)
        }).addDisposableTo(disposeBag)
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
            case .next(let messages):
                
                if messages.count > 0 {
                    self?.loading = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
                
                self?.appendMessages(messages)
            case .Error:
                self?.loading = false
            default:
                break;
            }
        }.addDisposableTo(disposeBag)
    }
    
    fileprivate func appendMessages(_ messages: [ShoutitKit.Notification]) {
        self.messages.append(contentsOf: messages)
        self.messages = self.messages.unique()
        self.tableView.reloadData()
    }
    
    fileprivate func insertMessage(_ message: ShoutitKit.Notification) {
        
        self.tableView.beginUpdates()
        
        self.messages.insert(message, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        self.tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationsTableViewCell

        let message =  messages[indexPath.row]
        
        cell.bindWithNotificationMessage(message)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message =  messages[indexPath.row]
        
        markMessageAsRead(message)
        openMessageObject(message)
    }
    
    @IBAction func moreAction() {
        
        let actionSheetController = UIAlertController(title: NSLocalizedString("More", comment: "Notifications Screen Action Sheet"), message: nil, preferredStyle: .actionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Mark all as read", comment: "Notifications Screen Action Sheet"), style: .destructive, handler: { (action) -> Void in
            self.markAllAsRead()
        }))
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Notification Settings", comment: "Notifications Screen Action Sheet"), style: .default, handler: { (action) -> Void in
            self.openNotificationSettings()
        }))
        
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Notifications Screen Action Sheet"), style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.navigationController?.present(actionSheetController, animated: true, completion: nil)
    }
    
    func markAllAsRead() {
        
        var readedNotifications : [ShoutitKit.Notification] = []
        
        messages.each { (notif) -> () in
            readedNotifications.append(notif.readCopy())
        }
        
        MBProgressHUD.showAdded(to: self.tableView, animated: true)
        
        APINotificationsService.markAllAsRead().subscribe(onNext: { [weak self] () -> Void in
            MBProgressHUD.hideAllHUDs(for: self?.tableView, animated: true)
            
            self?.messages = readedNotifications
            self?.tableView.reloadData()
        }, onError: { [weak self] (error) -> Void in
            MBProgressHUD.hideAllHUDs(for: self?.tableView, animated: true)
            self?.tableView.reloadData()
        }, onCompleted: { () -> Void in
                
        }, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func markMessageAsRead(_ notification: ShoutitKit.Notification) {
        
        let notificationIdx = messages.index(of: notification)
        
        MBProgressHUD.showAdded(to: self.tableView, animated: true)
        
        APINotificationsService.markNotificationAsRead(notification).subscribe(onNext: {
            MBProgressHUD.hideAllHUDs(for: self.tableView, animated: true)
            
            if let idx = notificationIdx {
                
                let readedCopy = notification.readCopy()
                
                self.messages.remove(at: idx)
                self.messages.insert(readedCopy, at: idx)
            }
            
            self.tableView.reloadData()
        }, onError: { [weak self] (error) -> Void in
            MBProgressHUD.hideAllHUDs(for: self?.tableView, animated: true)
            self?.showError(error)
            self?.tableView.reloadData()
        }, onCompleted: { () -> Void in
                
        }, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func openMessageObject(_ notification: ShoutitKit.Notification) {
        guard let path = notification.appPath, let url = URL(string: path) else { return }
//        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.shared.openURL(url)
//        }
    }
    
    func openNotificationSettings() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            loadNextPage()
        }
    }
}
