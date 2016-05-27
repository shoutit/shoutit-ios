//
//  CreateShoutTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CreateShoutTextCell: UITableViewCell {

    private(set) var reuseDisposeBag = DisposeBag()
    @IBOutlet var textField : UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
