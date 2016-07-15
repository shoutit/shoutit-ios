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
    
    override func configureCell(cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        
        let profile : Profile = cellViewModel.profile 
        
        cell.nameLabel.text = profile.name
        
        if (members.contains{$0.id == profile.id}) {
            cell.listenersCountLabel.text = NSLocalizedString("Already a member", comment: "")
            cell.nameLabel.alpha = 0.5
            cell.listenersCountLabel.alpha = 0.5
            cell.thumbnailImageView.alpha = 0.5
        } else {
            cell.listenersCountLabel.text = NSLocalizedString("Tap to add to chat", comment: "")
            cell.nameLabel.alpha = 1.0
            cell.listenersCountLabel.alpha = 1.0
            cell.thumbnailImageView.alpha = 1.0
        }
        
        if case .Some(.Page(_)) = Account.sharedInstance.loginState {
            cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPagePlaceholder())
        }
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        cell.listenButton.hidden = true
    }
}
