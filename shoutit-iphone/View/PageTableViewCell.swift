//
//  PageTableViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 09.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class PageTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var listenersCountLabel : UILabel!
    @IBOutlet var listenButton : ListenButton!
    @IBOutlet var ratingView : RatingView!

    
    func bindWithProfileViewModel(profileViewModel: ProfilesListCellViewModel) {
        let profile = profileViewModel.profile
        
        self.listenButton.listenState = profileViewModel.isListening ? .Listening : .Listen
        
        self.profileImageView
    }
    
}
