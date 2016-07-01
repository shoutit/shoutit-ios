//
//  LikeButton.swift
//  shoutit
//
//  Created by Piotr Bernad on 01/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LikeButton: UIButton {

    func setLiked() {
        self.setImage(UIImage(named: "like_on"), forState: .Normal)
    }
    
    func setUnliked() {
        self.setImage(UIImage(named: "like_off"), forState: .Normal)
    }

}
