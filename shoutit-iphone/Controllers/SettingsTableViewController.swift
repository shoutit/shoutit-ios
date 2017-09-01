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
    fileprivate let cellReuseID = "SettingsTableViewCell"
    
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
    
    fileprivate func setupRX() {
        
        Account.sharedInstance.userSubject.subscribe(onNext: { (user) in
            for option in self.models.value {
                if let refresh = option.refresh {
                    refresh(option)
                }
            }
            self.tableView.reloadData()
            
        }).addDisposableTo(disposeBag)
        // bind table view
        models.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: cellReuseID, cellType: SettingsTableViewCell.self)) {[weak self] (row, option, cell) in
                
                cell.titleLabel.text = option.name
                cell.subtitleLabel?.text = option.detail
                let isLastCell = self?.models.value.count == row + 1
                cell.separatorMarginConstraint.constant = isLastCell ? 0.0 : 10.0
                cell.separatorHeightConstraint.constant = isLastCell ? 1.0 : 1.0 / UIScreen.main.scale
                cell.separatorView.backgroundColor = isLastCell ? UIColor(shoutitColor: .separatorGray) : UIColor.black.withAlphaComponent(0.12)
                cell.selectionStyle = .none
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx.modelSelected(SettingsOption.self)
            .subscribe(onNext: { (option) in
                option.action(option)
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func ignoresToggleMenu() -> Bool {
        return ignoreMenuButton
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
