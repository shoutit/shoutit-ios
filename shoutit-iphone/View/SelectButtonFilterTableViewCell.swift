//
//  SelectButtonFilterTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class SelectButtonFilterTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var button: SelectButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
