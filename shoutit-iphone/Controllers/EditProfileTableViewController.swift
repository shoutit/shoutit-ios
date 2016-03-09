//
//  EditProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileTableViewController: UITableViewController {
    
    var viewModel: EditProfileTableViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // nav bar
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        cancelBarButtonItem
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.reuseIdentifier, forIndexPath: indexPath)
        
        if let cell = cell as? EditProfileTextFieldTableViewCell {
            cell.textField.placeholder = cellViewModel.placeholderText
        } else if let cell = cell as? EditProfileTextViewTableViewCell {
            cell.textView.placeholderLabel?.text = cellViewModel.placeholderText
            
            cell.textView.rx_text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged()
                .subscribeNext{[weak textView = cell.textView] (text) in
                    textView?.detailLabel?.text = "\(text.characters.count)/250"
                }
                .addDisposableTo(cell.disposeBag)
            
            cell.textView.contentSizeDidChange = {[weak tableView, weak cell] (size) in
                guard let cell = cell else { return }
                guard let tableView = tableView else { return }
                guard let heightConstraint = cell.heightConstraint else { return }
                guard heightConstraint.constant != size.height else { return }
                tableView.beginUpdates()
                heightConstraint.constant = max(75, size.height)
                tableView.endUpdates()
                cell.textView.setNeedsLayout()
                cell.textView.layoutIfNeeded()
            }
        } else if let cell = cell as? EditProfileSelectButtonTableViewCell {
            
        }
        
        return cell
    }
}
