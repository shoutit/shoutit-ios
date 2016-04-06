//
//  BigLabelButtonFilterTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class BigLabelButtonFilterTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var button: BigLabelSelectButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
