//
//  SettingsTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class SettingsTableViewController: UITableViewController {
    
    // consts
    private let cellReuseID = "SettingsTableViewCell"
    
    // model
    var models: Variable<[SettingsOption]>!
    
    // toggle menu
    var ignoreMenuButton = false
    
    // RX
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyNavigationItems()
        setupRX()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        Account.sharedInstance.userSubject.subscribeNext { (user) in
            self.tableView.reloadData()
        }.addDisposableTo(disposeBag)
        
        // bind table view
        models.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: SettingsTableViewCell.self)) {[weak self] (row, option, cell) in
                cell.titleLabel.text = option.name
                cell.subtitleLabel?.text = option.detail
                let isLastCell = self?.models.value.count == row + 1
                cell.separatorMarginConstraint.constant = isLastCell ? 0.0 : 10.0
                cell.separatorHeightConstraint.constant = isLastCell ? 1.0 : 1.0 / UIScreen.mainScreen().scale
                cell.separatorView.backgroundColor = isLastCell ? UIColor(shoutitColor: .SeparatorGray) : UIColor.blackColor().colorWithAlphaComponent(0.12)
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx_modelSelected(SettingsOption.self)
            .subscribeNext { (option) in
                option.action()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func ignoresToggleMenu() -> Bool {
        return ignoreMenuButton
    }
}