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
import Validator

class SettingsFormViewController: UITableViewController {
    
    var viewModel: SettingsFormViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        title = viewModel.title
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
        case .TextField(let value, let placeholder, let secureTextEntry, let validator):
            let textFieldCell = cell as! SettingsFormTextFieldTableViewCell
            textFieldCell.textField.text = value
            textFieldCell.textField.placeholder = placeholder
            textFieldCell.textField.secureTextEntry = secureTextEntry
            textFieldCell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self](text) in
                    self.viewModel.cellViewModels[indexPath.row] = .TextField(value: text, placeholder: placeholder, secureTextEntry: secureTextEntry, validator: validator)
                }
                .addDisposableTo(textFieldCell.reuseDisposeBag)
            
            setupTextField(textFieldCell.textField, validator: validator, disposeBag: textFieldCell.reuseDisposeBag)
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
    
    private func setupTextField(textField: BorderedMaterialTextField, validator: (String -> ValidationResult)?, disposeBag: DisposeBag) {
        textField.font = UIFont.systemFontOfSize(18.0)
        textField.textColor = MaterialColor.black
        
        textField.titleLabel = UILabel()
        textField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textField.titleLabelColor = MaterialColor.grey.lighten1
        textField.titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        textField.clearButtonMode = .WhileEditing
        
        textField.detailLabel = UILabel()
        textField.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textField.detailLabelActiveColor = MaterialColor.red.accent3
        
        if let validator = validator {
            textField.addValidator(validator, withDisposeBag: disposeBag)
        }
    }
}
