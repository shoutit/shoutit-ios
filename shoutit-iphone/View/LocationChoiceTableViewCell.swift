//
//  LocationChoiceTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class LocationChoiceTableViewCell: UITableViewCell {
    fileprivate(set) var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var button: SelectionButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}

extension LocationChoiceTableViewCell: ReusableView {}
