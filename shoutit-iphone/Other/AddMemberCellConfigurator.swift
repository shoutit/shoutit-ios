//
//  AddMemberCellConfigurator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class AddMemberCellConfigurator: ProfileCellConfigurator {

    var members : [Profile]!
    
    override func configureCell(_ cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        
        let profile : Profile = cellViewModel.profile
        
        cell.nameLabel.text = profile.name
        
        if (members.contains{$0.id == profile.id}) {
            cell.listenersCountLabel.text = NSLocalizedString("Already a member", comment: "Add Chat Member subtitle")
            cell.nameLabel.alpha = 0.5
            cell.listenersCountLabel.alpha = 0.5
            cell.thumbnailImageView.alpha = 0.5
        } else {
            cell.listenersCountLabel.text = NSLocalizedString("Tap to add to chat", comment: "Add Chat Member subtitle")
            cell.nameLabel.alpha = 1.0
            cell.listenersCountLabel.alpha = 1.0
            cell.thumbnailImageView.alpha = 1.0
        }
        
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: cellViewModel.profile.type == .Page ? UIImage.squareAvatarPagePlaceholder() : UIImage.squareAvatarPlaceholder())
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        cell.listenButton.isHidden = true
    }
}
