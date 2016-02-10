//
//  MenuTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, Navigation {
    
    var rootController : RootController?
    let viewModel = MenuViewModel()
    var footerHeight : CGFloat = 0
    
    private let kTableHeaderHeight: CGFloat = 240.0
    
    @IBOutlet var headerView : MenuHeaderView?
    
    var overlayView : UIView? {
        didSet {
            guard let overlay = overlayView else {
                oldValue?.removeFromSuperview()
                return
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action:  "dismiss")
            overlay.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        updateFooterView()
        
        let user = Account.sharedInstance.authData?.user
        headerView?.fillWith(user)
    }
    
    func setupBackgroundView() {
        let backgroundView = UIImageView(image: UIImage(named: "auth_screen_bg_pattern"))
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        backgroundView.contentMode = .ScaleAspectFill
        tableView.backgroundView = backgroundView
        
        tableView.layer.borderColor = UIColor.darkGrayColor().CGColor
        tableView.layer.borderWidth = 1
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
        
        cell.bindWith(item)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = viewModel.navigationItemForIndexPath(indexPath)
        triggerActionWithItem(item)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48.0
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
    
    // MARK: Scroll Handling
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateFooterView()
    }
    
    func updateFooterView() {
        if (UIScreen.mainScreen().bounds.height < tableView.frame.height) {
            return
        }
        
        footerHeight = CGRectGetHeight(tableView.frame) - kTableHeaderHeight - 8 * 48.0
        
        if let footer = tableView.tableFooterView {
            if tableView.contentOffset.y > 0 {
                footer.frame.size.height = footerHeight + tableView.contentOffset.y
            } else {
                footer.frame.size.height = footerHeight
            }
        }
    }
}
