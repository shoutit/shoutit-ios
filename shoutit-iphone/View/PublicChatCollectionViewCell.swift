//
//  PublicChatCollectionViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 05.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class PublicChatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var secondLineLabel: UILabel!
}

extension PublicChatCollectionViewCell : ReusableView, NibLoadableView {
    static var defaultReuseIdentifier: String { return "PublicChatCollectionViewCell" }
    static var nibName: String { return "PublicChatsPreviewCell" }
}

extension PublicChatCollectionViewCell {
    func bindWithConversation(conversation: MiniConversation) {
        self.firstLineLabel.attributedText = conversation.firstLineText()
        self.secondLineLabel.attributedText = conversation.secondLineText()
        self.imageView.sh_setImageWithURL(conversation.imageURL(), placeholderImage: UIImage.backgroundPattern())
    }
}