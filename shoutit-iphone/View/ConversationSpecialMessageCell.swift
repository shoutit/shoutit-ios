//
//  ConversationSpecialMessageCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ConversationSpecialMessageCell: UITableViewCell, ConversationCell {

    weak var imageHeightConstraint: NSLayoutConstraint?
    weak var activityIndicator: UIActivityIndicatorView?
    weak var avatarImageView: UIImageView?
    var avatarButton: UIButton?
    weak var timeLabel: UILabel?
    var reuseDisposeBag: DisposeBag = DisposeBag()
    
    func hydrateAvatarImageView(_ imageView: UIImageView, withAvatarPath path: String?) {
        
    }
    
    func hideImageView() {
        
    }
    
    func unHideImageView() {
        
    }
}
