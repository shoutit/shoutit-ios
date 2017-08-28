//
//  ProfileCellConfigurator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCellConfigurator: AnyObject {
    func configureCell(_ cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        cell.nameLabel.text = cellViewModel.profile.name
        cell.listenersCountLabel.text = cellViewModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: cellViewModel.profile.type == UserType.Page ? UIImage.squareAvatarPagePlaceholder() : UIImage.squareAvatarPlaceholder())
        
        
        guard showsListenButton else {
            cell.listenButton.isHidden = true
            return
        }
        
        let listenButtonImage = cellViewModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        cell.listenButton.setImage(listenButtonImage, for: UIControlState())
        cell.listenButton.isHidden = cellViewModel.hidesListeningButton()
    }
}


