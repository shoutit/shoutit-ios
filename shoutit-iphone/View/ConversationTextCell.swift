//
//  ConversationTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class ConversationTextCell: UITableViewCell, ConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView? {
        didSet {
            avatarImageView?.userInteractionEnabled = true
            addAvatarButtonToAvatarImageView()
        }
    }
    var avatarButton: UIButton?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel!
    var reuseDisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unHideImageView()
        reuseDisposeBag = DisposeBag()
    }
}
