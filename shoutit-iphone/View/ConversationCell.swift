//
//  ConversationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol MessagePresenting {
    func bindWithMessage(message: Message, previousMessage: Message?)
}

class ConversationCell: UITableViewCell, MessagePresenting {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    func bindWithMessage(message: Message, previousMessage: Message?) {
        fatalError("Please Implement this method in subclass")
    }
}
