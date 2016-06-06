//
//  CreateShoutSelectCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class CreateShoutSelectCell: UITableViewCell {
    
    private(set) var reuseDisposeBag = DisposeBag()
    @IBOutlet var selectButton : SelectionButton!
 
    func fillWithFilter(filter: Filter, currentValue: FilterValue?) {
        if let value = currentValue {
            self.selectButton.setTitle(value.name, forState: .Normal)
        } else {
            self.selectButton.setTitle(filter.name, forState: .Normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
