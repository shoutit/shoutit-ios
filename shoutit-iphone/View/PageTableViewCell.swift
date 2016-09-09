//
//  PageTableViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 09.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift

class PageTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var listenersCountLabel : UILabel!
    @IBOutlet var listenButton : ListenButton!
    @IBOutlet var ratingView : RatingView!
    
    var reuseDisposeBag = DisposeBag()
    
    func bindWithProfileViewModel(profileViewModel: ProfilesListCellViewModel) {

        self.listenButton.listenState = profileViewModel.isListening ? .Listening : .Listen
        
        
        self.nameLabel.text = profileViewModel.profile.name
        self.listenersCountLabel.text = profileViewModel.listeningCountString()
        
        self.profileImageView.sh_setImageWithURL(profileViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPagePlaceholder())
    }
    
}

extension PageTableViewCell: NibLoadableView, ReusableView {
    static var defaultReuseIdentifier: String {
        return "PageTableViewCell"
    }
    
    static var nibName: String {
        return "PageTableViewCell"
    }
}