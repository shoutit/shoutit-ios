//
//  ShoutDetailButtonTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class ShoutDetailButtonTableViewCell: UITableViewCell {
    
    var reuseDisposeBag: DisposeBag?
    
    @IBOutlet weak var button: CustomUIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = nil
    }
}