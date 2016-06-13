//
//  CreditTransactionsTableViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 10/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import DZNEmptyDataSet

class CreditTransactionsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var flowDelegate : FlowController?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let cellIdentifier = "NotificationsCellIdentifier"
    private let disposeBag = DisposeBag()
    private var transactions : [Transaction] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadTransactions()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(reloadTransactions), forControlEvents: .ValueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshControl?.endRefreshing()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No transactions to show", comment: ""))
    }
    
    @IBAction func reloadTransactions() {
        loading = true
        
        APICreditsService.requestTransactions(before: nil).subscribeNext { [weak self] (transactions) -> Void in
            self?.loading = false
            self?.refreshControl?.endRefreshing()
            self?.appendTransactions(transactions)
            }.addDisposableTo(disposeBag)
    }
    
    func loadNextPage() {
        if loading {
            return
        }
        
        guard let lastTransaction = transactions.last else {
            return
        }
        
        loading = true
        
        APICreditsService.requestTransactions(before: lastTransaction.createdAt).subscribe { [weak self] (event) in
            switch event {
            case .Next(let transactions):
                
                if transactions.count > 0 {
                    self?.loading = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.hidden = true
                }
                
                self?.appendTransactions(transactions)
            case .Error:
                self?.loading = false
            default:
                break;
            }
            }.addDisposableTo(disposeBag)
    }
    
    private func appendTransactions(messages: [Transaction]) {
        self.transactions.appendContentsOf(messages)
        self.transactions = self.transactions.unique()
        self.tableView.reloadData()
    }
    
    private func insertMessage(transaction: Transaction) {
        
        self.tableView.beginUpdates()
        
        self.transactions.insert(transaction, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        self.tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NotificationsTableViewCell
        
        let transaction =  transactions[indexPath.row]
        
        cell.bindWithTransaction(transaction)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let transaction =  transactions[indexPath.row]
        openMessageObject(transaction)
    }
    
    func openMessageObject(transaction: Transaction) {
        guard let path = transaction.appPath, url = NSURL(string: path) else { return }
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
