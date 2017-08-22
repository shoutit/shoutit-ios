//
//  ConversationProfileCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import RxSwift

final class ConversationProfileCell: UITableViewCell, ThumbedConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView? {
        didSet {
            avatarImageView?.isUserInteractionEnabled = true
            addAvatarButtonToAvatarImageView()
        }
    }
    var avatarButton: UIButton?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    var reuseDisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unHideImageView()
        reuseDisposeBag = DisposeBag()
    }
}
