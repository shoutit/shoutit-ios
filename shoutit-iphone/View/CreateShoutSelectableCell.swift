//
//  CreateShoutSelectableCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CreateShoutSelectableCell: UITableViewCell, Borderable {
    
    private(set) var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var internalContentView: BorderedView!
    @IBOutlet weak var selectionTitleLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tickImageView.image = selected ? UIImage.tickIcon() : nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}