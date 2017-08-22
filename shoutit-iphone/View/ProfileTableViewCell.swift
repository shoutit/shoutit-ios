//
//  ProfileTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class ProfileTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightConstraint.constant = 1 / UIScreen.main.scale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
        thumbnailImageView.image = nil
    }
}

extension ProfileTableViewCell: NibLoadableView, ReusableView {}
