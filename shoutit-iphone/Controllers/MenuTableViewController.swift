//
//  MenuTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class MenuTableViewController: UITableViewController, Navigation {
    
    var rootController : RootController?
    var viewModel: MenuViewModel!
    private let disposeBag = DisposeBag()
    
    var selectedNavigationItem : NavigationItem?
    
    private let kTablePrimaryCellHeight: CGFloat = 48.0
    private let kTableSecondaryCellHeight: CGFloat = 44.0
    private let kTableHeaderHeight: CGFloat = 288.0
    private let kTableFooterHeight: CGFloat = 44.0
    
    @IBOutlet var headerView : MenuHeaderView?
    @IBOutlet var versionLabel : UILabel?
    
    private let badgeLabel = CustomUILabel()
    
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
        precondition(viewModel != nil)
        
        // add border
        tableView.layer.borderColor = UIColor.darkGrayColor().CGColor
        tableView.layer.borderWidth = 1
        
        headerView?.fillWith(viewModel.loginState)
        
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String {
            
            #if STAGING
                let appName = "Shoutit Staging"
            #else
                let appName = "Shoutit"
            #endif
            
            versionLabel?.text = "\(appName) \(version) (\(build))"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setScrollEnabledAccordinglyToTableViewContentHeight()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        
        let isNotLastSection = indexPath.section + 1 != viewModel.sections().count
        let itemIsLastInSection = indexPath.row + 1 == viewModel.numberOfRowsInSection(indexPath.section)
        cell.bindWith(item, current: item == selectedNavigationItem)
        cell.setSeparatorVisible(isNotLastSection && itemIsLastInSection)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = viewModel.navigationItemForIndexPath(indexPath)
        triggerActionWithItem(item)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForRowAtSection(indexPath.section)
    }
    
    // MARK: User Interactions
    
    @IBAction func profileAction(sender: AnyObject) {
        triggerActionWithItem(.Profile)
    }
    
    @IBAction func createShout(sender: AnyObject) {
        triggerActionWithItem(.CreateShout)
    }
    
    @IBAction func changeLocation(sender: AnyObject) {
        triggerActionWithItem(.Location)
    }
    
    @IBAction func showCreditsAction(sender: AnyObject) {
        triggerActionWithItem(.Credits)
    }
    
    override func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Bussines Logic
    
    func triggerActionWithItem(navigationItem: NavigationItem) {
        guard let rootController = rootController else { return }
        if case .SwitchFromPageToUser = navigationItem {
            Account.sharedInstance.switchToUser()
        } else {
            rootController.openItem(navigationItem)
        }
    }
}

private extension MenuTableViewController {
    
    private func setScrollEnabledAccordinglyToTableViewContentHeight() {
        let cellsHeight = Array(viewModel.sections().indices).reduce(CGFloat()) { $0 + CGFloat(viewModel.numberOfRowsInSection($1)) * heightForRowAtSection($1) }
        let contentHeight = kTableHeaderHeight + kTableFooterHeight + cellsHeight
        tableView.scrollEnabled = contentHeight > tableView.frame.height
    }
    
    private func heightForRowAtSection(section: Int) -> CGFloat {
        if case .Main = viewModel.sections()[section] {
            return kTablePrimaryCellHeight
        }
        return kTableSecondaryCellHeight
    }
}
