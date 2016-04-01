//
//  MenuTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class MenuTableViewController: UITableViewController, Navigation {
    
    var rootController : RootController?
    let viewModel = MenuViewModel()
    private let disposeBag = DisposeBag()
    
    var selectedNavigationItem : NavigationItem?
    
    private let kTablePrimaryCellHeight: CGFloat = 48.0
    private let kTableSecondaryCellHeight: CGFloat = 44.0
    private let kTableHeaderHeight: CGFloat = 240.0
    private let kTableFooterHeight: CGFloat = 44.0
    
    @IBOutlet var headerView : MenuHeaderView?
    @IBOutlet var versionLabel : UILabel?
    
    var overlayView : UIView? {
        didSet {
            guard let overlay = overlayView else {
                oldValue?.removeFromSuperview()
                return
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(MenuTableViewController.dismiss))
            overlay.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add border
        tableView.layer.borderColor = UIColor.darkGrayColor().CGColor
        tableView.layer.borderWidth = 1
        
        // lock scroll
        let contentHeight = kTableHeaderHeight + kTableFooterHeight + 5 * kTablePrimaryCellHeight + 3 * kTableSecondaryCellHeight
        tableView.scrollEnabled = contentHeight > tableView.frame.height
        
        Account.sharedInstance.userSubject.subscribeNext { (user: User?) in
            self.headerView?.fillWith(user)
        }.addDisposableTo(disposeBag)
        
        let user = Account.sharedInstance.user
        headerView?.fillWith(user)
        
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String {
            
            #if STAGING
                let appName = "Shoutit Staging"
            #else
                let appName = "Shoutit"
            #endif
            
            versionLabel?.text = "\(appName) \(version) (\(build))"
        }
        
    }
    
    // MARK: Table View Handling
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sections().count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = viewModel.cellIdentifierForSection(indexPath.section)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as! MenuCell
        let item = viewModel.navigationItemForIndexPath(indexPath)
        
        cell.bindWith(item, current: item == self.selectedNavigationItem)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = viewModel.navigationItemForIndexPath(indexPath)
        triggerActionWithItem(item)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if case (0..<5) = indexPath.row {
            return kTablePrimaryCellHeight
        }
        return kTableSecondaryCellHeight
    }
    
    // MARK: User Interactions
    
    @IBAction func profileAction(sender: AnyObject) {
        triggerActionWithItem(.Profile)
    }
    
    @IBAction func createShout(sender: AnyObject) {
        triggerActionWithItem(.Shout)
    }
    
    @IBAction func changeLocation(sender: AnyObject) {
        triggerActionWithItem(.Location)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Bussines Logic
    
    func triggerActionWithItem(navigationItem: NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
}
