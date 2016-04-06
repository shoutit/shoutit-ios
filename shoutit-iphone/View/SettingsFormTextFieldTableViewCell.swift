//
//  SettingsFormTextFieldTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class SettingsFormTextFieldTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var textField: BorderedMaterialTextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
