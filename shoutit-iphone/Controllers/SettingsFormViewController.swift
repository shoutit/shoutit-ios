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
    fileprivate let disposeBag = DisposeBag()
    
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
    
    fileprivate func setupRX() {
        
        viewModel
            .progressSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (show) in
                guard let `self` = self else { return }
                if show {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel
            .errorSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self](error) in
                self?.showError(error)
            }).addDisposableTo(disposeBag)
        
        viewModel
            .successSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (success) in
                self?.showSuccessMessage(success.message)
                self?.pop()
            }).addDisposableTo(disposeBag)
    }
    
    override func ignoresToggleMenu() -> Bool {
        return ignoreMenuButton
    }
}

extension SettingsFormViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierForCellViewModel(cellViewModel), for: indexPath)
        switch cellViewModel {
        case .button(let title, let action):
            let buttonCell = cell as! SettingsFormButtonTableViewCell
            buttonCell.button.setTitle(title, for: UIControlState())
            buttonCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: {
                    action()
                })
                .addDisposableTo(buttonCell.reuseDisposeBag)
        case .textField(let value, let type):
            let textFieldCell = cell as! SettingsFormTextFieldTableViewCell
            textFieldCell.textField.text = value
            textFieldCell.textField.placeholder = type.placeholder
            textFieldCell.textField.isSecureTextEntry = type.secureTextEntry
            textFieldCell.textField
                .rx.text
                .asDriver()
                .drive(onNext: { [unowned self](text) in
                    self.viewModel.cellViewModels[indexPath.row] = .textField(value: text, type: type)
                })
                .addDisposableTo(textFieldCell.reuseDisposeBag)
            
            if let validator = type.validator {
                textFieldCell.textField.addValidator(validator, withDisposeBag: textFieldCell.reuseDisposeBag)
            }
        }
        return cell
    }
    
}

extension SettingsFormViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        switch cellViewModel {
        case .button:
            return 44
        case .textField:
            return 100
        }
    }
}

private extension SettingsFormViewController {
    
    func reuseIdentifierForCellViewModel(_ model: SettingsFormCellViewModel) -> String {
        switch model {
        case .button:
            return "ButtonCell"
        case .textField:
            return "TextFieldCell"
        }
    }
}
