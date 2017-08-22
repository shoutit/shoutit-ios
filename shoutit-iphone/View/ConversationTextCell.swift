//
//  ConversationTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift

final class ConversationTextCell: UITableViewCell, ConversationCell {
    
    typealias _PatternTapResponder = @convention(block) (String!) -> Void
    
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
    @IBOutlet weak var messageLabel: ResponsiveLabel!
    var reuseDisposeBag = DisposeBag()
    var urlHandler: ((String) -> Void)?
    var phoneNumberHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupURLResponder()
        setupPhoneNumberResponder()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unHideImageView()
        reuseDisposeBag = DisposeBag()
    }
    
    fileprivate func setupURLResponder() {
        messageLabel.userInteractionEnabled = true
        let urlResponder: _PatternTapResponder = { [weak self] (url) in
            self?.urlHandler?(url)
        }
        let attributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor(shoutitColor: .ShoutitLightBlueColor) ,
                                                NSUnderlineStyleAttributeName : 1,
                                                RLTapResponderAttributeName : unsafeBitCast(urlResponder, to: AnyObject.self)]
        messageLabel.enableURLDetectionWithAttributes(attributes)
    }
    
    fileprivate func setupPhoneNumberResponder() {
        messageLabel.userInteractionEnabled = true
        let urlResponder: _PatternTapResponder = { [weak self] (url) in
            self?.phoneNumberHandler?(url)
        }
        let attributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor(shoutitColor: .ShoutitLightBlueColor) ,
                                                NSUnderlineStyleAttributeName : 1,
                                                RLTapResponderAttributeName : unsafeBitCast(urlResponder, to: AnyObject.self)]
        messageLabel.enablePhoneNumberDetectionWithAttribtues(attributes)
    }
}
