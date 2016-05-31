//
//  ProfileCellConfigurator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCellConfigurator: AnyObject {
    func configureCell(cell: ProfileTableViewCell, cellViewModel: ProfilesListCellViewModel, showsListenButton: Bool) {
        cell.nameLabel.text = cellViewModel.profile.name
        cell.listenersCountLabel.text = cellViewModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        guard showsListenButton else {
            cell.listenButton.hidden = true
            return
        }
        
        let listenButtonImage = cellViewModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        cell.listenButton.setImage(listenButtonImage, forState: .Normal)
        cell.listenButton.hidden = cellViewModel.hidesListeningButton()
    }
}


