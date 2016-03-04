//
//  PostSignupSuggestionsTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class PostSignupSuggestionsTableViewCell: UITableViewCell {
    
    var reuseDisposeBag: DisposeBag?
    
    @IBOutlet weak var thumbnailImageView: CustomUIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorViewHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = nil
    }
}
