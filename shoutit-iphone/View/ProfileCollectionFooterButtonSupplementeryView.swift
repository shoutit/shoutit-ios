//
//  ProfileCollectionFooterButtonSupplementeryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

enum ProfileCollectionFooterButtonType {
    case Green
    case Gray
}

final class ProfileCollectionFooterButtonSupplementeryView: UICollectionReusableView {
    
    var reuseDisposeBag: DisposeBag?
    
    var type: ProfileCollectionFooterButtonType? = .Gray {
        didSet {
            setupAppearanceForType(type)
        }
    }
    @IBOutlet weak var button: CustomUIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAppearanceForType(type)
    }
    
    private func setupAppearanceForType(type: ProfileCollectionFooterButtonType?) {
        
        guard let type = type else {
            return
        }
        
        switch type {
        case .Green:
            backgroundColor = UIColor.whiteColor()
            button.backgroundColor = UIColor(shoutitColor: .PrimaryGreen)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .Gray:
            backgroundColor = UIColor(shoutitColor: .BackgroundLightGray)
            button.backgroundColor = UIColor(shoutitColor: .ButtonBackgroundGray)
            button.setTitleColor(UIColor(shoutitColor: .FontLighterGray), forState: .Normal)
        }
    }
}
