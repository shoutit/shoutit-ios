//
//  ConversationMemberCellConfigurator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationMemberCellConfigurator: ProfileCellConfigurator {
    var blocked : [String]!
    var admins : [String]!
    var canAdministrate = false
    
    override func configureCell(cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        
        let profile : Profile = cellViewModel.profile
        
        cell.nameLabel.text = profile.name
        
        let isAdmin = admins.contains{$0 == profile.id}
        let isBlocked = blocked.contains{$0 == profile.id}
       
        let subtitle = NSMutableAttributedString()
        
        if isAdmin {
            let adminString = NSAttributedString(string: NSLocalizedString("Administrator", comment: ""),
                                                 attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            subtitle.appendAttributedString(adminString)
            subtitle.appendAttributedString(NSAttributedString(string: "  "))
        }
        
        if isBlocked {
            let blockedString = NSAttributedString(string: NSLocalizedString("Blocked", comment: ""),
                                                   attributes: [NSForegroundColorAttributeName: UIColor(shoutitColor: .PrimaryGreen)])
            
            subtitle.appendAttributedString(blockedString)
        }
        
        cell.listenersCountLabel.attributedText = subtitle
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        cell.listenButton.hidden = true
        
        if canAdministrate {
            cell.accessoryType = .DisclosureIndicator
        }
    }
}
