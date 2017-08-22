//
//  CreateShoutMobileCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 06/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CreateShoutMobileCell: UITableViewCell {
    
    fileprivate(set) var reuseDisposeBag = DisposeBag()
    @IBOutlet var mobileTextField : UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
