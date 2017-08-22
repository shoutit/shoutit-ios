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
    fileprivate let disposeBag = DisposeBag()
    
    var selectedNavigationItem : NavigationItem?
    
    fileprivate let kTablePrimaryCellHeight: CGFloat = 48.0
    fileprivate let kTableSecondaryCellHeight: CGFloat = 44.0
    fileprivate let kTableHeaderHeight: CGFloat = 288.0
    fileprivate let kTableFooterHeight: CGFloat = 44.0
    
    @IBOutlet var headerView : MenuHeaderView?
    @IBOutlet var versionLabel : UILabel?
    
    fileprivate let badgeLabel = CustomUILabel()
    
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
        tableView.layer.borderColor = UIColor.darkGray.cgColor
        tableView.layer.borderWidth = 1
        
        headerView?.fillWith(viewModel.loginState)
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            
            #if STAGING
                let appName = "Shoutit Staging"
            #else
                let appName = "Shoutit"
            #endif
            
            versionLabel?.text = "\(appName) \(version) (\(build))"
            
            subscribeForStatsChange()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScrollEnabledAccordinglyToTableViewContentHeight()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Table View Handling
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections().count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = viewModel.cellIdentifierForSection(indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as! MenuCell
        let item = viewModel.navigationItemForIndexPath(indexPath)
        
        let isNotLastSection = indexPath.section + 1 != viewModel.sections().count
        let itemIsLastInSection = indexPath.row + 1 == viewModel.numberOfRowsInSection(indexPath.section)
        cell.bindWith(item, current: item == selectedNavigationItem)
        cell.setSeparatorVisible(isNotLastSection && itemIsLastInSection)
        
            if case .some(.page(let admin, _)) = Account.sharedInstance.loginState {
                if item == NavigationItem.SwitchFromPageToUser {
                    cell.setBadgeNumber(admin.stats?.totalUnreadCount ?? 0)
                } else {
                   cell.setBadgeNumber(0)
                }
            } else {
                cell.setBadgeNumber(0)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.navigationItemForIndexPath(indexPath)
        triggerActionWithItem(item)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAtSection(indexPath.section)
    }
    
    // MARK: User Interactions
    
    @IBAction func profileAction(_ sender: AnyObject) {
        triggerActionWithItem(.Profile)
    }
    
    @IBAction func createShout(_ sender: AnyObject) {
        triggerActionWithItem(.CreateShout)
    }
    
    @IBAction func changeLocation(_ sender: AnyObject) {
        triggerActionWithItem(.Location)
    }
    
    @IBAction func showCreditsAction(_ sender: AnyObject) {
        triggerActionWithItem(.Credits)
    }
    
    override func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Bussines Logic
    
    func triggerActionWithItem(_ navigationItem: NavigationItem) {
        guard let rootController = rootController else { return }
        if case .SwitchFromPageToUser = navigationItem {
            Account.sharedInstance.switchToUser()
        } else {
            rootController.openItem(navigationItem)
        }
    }
    
    func subscribeForStatsChange(){
        
        Account.sharedInstance.statsSubject.subscribeNext{ (stats) in
            self.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
}

private extension MenuTableViewController {
    
    func setScrollEnabledAccordinglyToTableViewContentHeight() {
        let cellsHeight = Array(viewModel.sections().indices).reduce(CGFloat()) { $0 + CGFloat(viewModel.numberOfRowsInSection($1)) * heightForRowAtSection($1) }
        let contentHeight = kTableHeaderHeight + kTableFooterHeight + cellsHeight
        tableView.isScrollEnabled = contentHeight > tableView.frame.height
    }
    
    func heightForRowAtSection(_ section: Int) -> CGFloat {
        if case .main = viewModel.sections()[section] {
            return kTablePrimaryCellHeight
        }
        return kTableSecondaryCellHeight
    }
}
