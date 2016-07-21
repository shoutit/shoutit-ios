//
//  SettingsFormViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Material
import MBProgressHUD

final class SettingsFormViewController: UITableViewController {
    
    var viewModel: SettingsFormViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // toggle menu
    var ignoreMenuButton : Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        title = viewModel.title
        setupRX()
        applyBackButton()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        viewModel
            .progressSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (show) in
                guard let `self` = self else { return }
                if show {
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .errorSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self](error) in
                self?.showError(error)
            }.addDisposableTo(disposeBag)
        
        viewModel
            .successSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (success) in
                self?.showSuccessMessage(success.message)
                self?.pop()
            }.addDisposableTo(disposeBag)
    }
    
    override func ignoresToggleMenu() -> Bool {
        return ignoreMenuButton
    }
}

extension SettingsFormViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierForCellViewModel(cellViewModel), forIndexPath: indexPath)
        switch cellViewModel {
        case .Button(let title, let action):
            let buttonCell = cell as! SettingsFormButtonTableViewCell
            buttonCell.button.setTitle(title, forState: .Normal)
            buttonCell.button
                .rx_tap
                .asDriver()
                .driveNext{
                    action()
                }
                .addDisposableTo(buttonCell.reuseDisposeBag)
        case .TextField(let value, let type):
            let textFieldCell = cell as! SettingsFormTextFieldTableViewCell
            textFieldCell.textField.text = value
            textFieldCell.textField.placeholder = type.placeholder
            textFieldCell.textField.secureTextEntry = type.secureTextEntry
            textFieldCell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self](text) in
                    self.viewModel.cellViewModels[indexPath.row] = .TextField(value: text, type: type)
                }
                .addDisposableTo(textFieldCell.reuseDisposeBag)
            
            if let validator = type.validator {
                textFieldCell.textField.addValidator(validator, withDisposeBag: textFieldCell.reuseDisposeBag)
            }
        }
        return cell
    }
    
}

extension SettingsFormViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        switch cellViewModel {
        case .Button:
            return 44
        case .TextField:
            return 100
        }
    }
}

private extension SettingsFormViewController {
    
    func reuseIdentifierForCellViewModel(model: SettingsFormCellViewModel) -> String {
        switch model {
        case .Button:
            return "ButtonCell"
        case .TextField:
            return "TextFieldCell"
        }
    }
}
