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

class SettingsTableViewController: UITableViewController {
    
    // consts
    private let cellReuseID = "SettingsTableViewCell"
    
    // model
    var models: Variable<[SettingsOption]>!
    
    // RX
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup left bar button item
        if let navigationController = self.navigationController {
            
            let leftBarButtonItem: UIBarButtonItem
            if self === navigationController.viewControllers[0] {
                leftBarButtonItem = UIBarButtonItem(image: UIImage.menuHamburger(), style: .Plain, target: self, action: "toggleMenu")
            } else {
                leftBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .Plain, target: self, action: "popViewController")
            }
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
        tableView.tableFooterView = UIView()
        setupRX()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // bind table view
        models.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: SettingsTableViewCell.self)) {[weak self] (row, option, cell) in
                cell.titleLabel.text = option.name
                if self?.models.value.count == row + 1 {
                    cell.separatorView.hidden = false
                }
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx_modelSelected(SettingsOption.self)
            .subscribeNext { (option) in
                option.action()
            }
            .addDisposableTo(disposeBag)
    }

    // MARK: - Navigation

    func popViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}