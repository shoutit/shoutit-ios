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
import ShoutitKit

class CreditTransactionsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    weak var flowDelegate : FlowController?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    fileprivate let cellIdentifier = "NotificationsCellIdentifier"
    fileprivate let disposeBag = DisposeBag()
    fileprivate var transactions : [Transaction] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadTransactions()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(reloadTransactions), for: .valueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 65.0
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshControl?.endRefreshing()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No transactions to show", comment: "No Transactions Message"))
    }
    
    @IBAction func reloadTransactions() {
        loading = true
        
      
        APICreditsService.requestTransactions(before: nil).subscribe(onNext: { [weak self] (transactions) -> Void in
            self?.loading = false
            self?.refreshControl?.endRefreshing()
            self?.appendTransactions(transactions)
            }).addDisposableTo(disposeBag)
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
            case .next(let transactions):
                
                if transactions.count > 0 {
                    self?.loading = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
                
                self?.appendTransactions(transactions)
            case .error:
                self?.loading = false
            default:
                break;
            }
            }.addDisposableTo(disposeBag)
    }
    
    fileprivate func appendTransactions(_ messages: [Transaction]) {
        self.transactions.append(contentsOf: messages)
        self.transactions = self.transactions.unique()
        self.tableView.reloadData()
    }
    
    fileprivate func insertMessage(_ transaction: Transaction) {
        
        self.tableView.beginUpdates()
        
        self.transactions.insert(transaction, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        self.tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationsTableViewCell
        
        let transaction =  transactions[indexPath.row]
        
        cell.bindWithTransaction(transaction)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction =  transactions[indexPath.row]
        openMessageObject(transaction)
    }
    
    func openMessageObject(_ transaction: Transaction) {
        guard let path = transaction.appPath, let url = URL(string: path) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func openNotificationSettings() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            loadNextPage()
        }
    }

}
