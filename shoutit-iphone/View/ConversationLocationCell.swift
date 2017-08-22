//
//  ConversationLocationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MapKit
import ShoutitKit
import RxSwift

final class ConversationLocationCell: UITableViewCell, ConversationCell {
    
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
    @IBOutlet weak var locationSnapshot: UIImageView!
    @IBOutlet weak var showLabel: UILabel?
    var reuseDisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicator?.isHidden = false
        self.showLabel?.isHidden = true
        unHideImageView()
        reuseDisposeBag = DisposeBag()
    }
}

