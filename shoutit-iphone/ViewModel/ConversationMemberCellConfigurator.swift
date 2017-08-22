//
//  ConversationMemberCellConfigurator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class ConversationMemberCellConfigurator: ProfileCellConfigurator {
    var blocked : [String]!
    var admins : [String]!
    var canAdministrate = false
    
    override func configureCell(_ cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        
        let profile : Profile = cellViewModel.profile
        
        cell.nameLabel.text = profile.name
        
        let isAdmin = admins.contains{$0 == profile.id}
        let isBlocked = blocked.contains{$0 == profile.id}
       
        let subtitle = NSMutableAttributedString()
        
        if isAdmin {
            let adminString = NSAttributedString(string: NSLocalizedString("Administrator", comment: "Conversation Profiles List - single user subtitle"),
                                                 attributes: [NSForegroundColorAttributeName: UIColor.red])
            subtitle.append(adminString)
            subtitle.append(NSAttributedString(string: "  "))
        }
        
        if isBlocked {
            let blockedString = NSAttributedString(string: NSLocalizedString("Blocked", comment: "Conversation Profiles List - single user subtitle"),
                                                   attributes: [NSForegroundColorAttributeName: UIColor(shoutitColor: .primaryGreen)])
            
            subtitle.append(blockedString)
        }
        
        cell.listenersCountLabel.attributedText = subtitle
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: cellViewModel.profile.type == .Page ? UIImage.squareAvatarPagePlaceholder() : UIImage.squareAvatarPlaceholder())
        
        
        cell.listenButton.isHidden = true
        
        if canAdministrate {
            cell.accessoryType = .disclosureIndicator
        }
    }
}
