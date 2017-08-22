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
    case green
    case gray
}

final class ProfileCollectionFooterButtonSupplementeryView: UICollectionReusableView {
    
    var reuseDisposeBag: DisposeBag?
    
    var type: ProfileCollectionFooterButtonType? = .gray {
        didSet {
            setupAppearanceForType(type)
        }
    }
    @IBOutlet weak var button: CustomUIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAppearanceForType(type)
    }
    
    fileprivate func setupAppearanceForType(_ type: ProfileCollectionFooterButtonType?) {
        
        guard let type = type else {
            return
        }
        
        switch type {
        case .green:
            backgroundColor = UIColor.white
            button.backgroundColor = UIColor(shoutitColor: .primaryGreen)
            button.setTitleColor(UIColor.white, for: UIControlState())
        case .gray:
            backgroundColor = UIColor(shoutitColor: .backgroundLightGray)
            button.backgroundColor = UIColor(shoutitColor: .buttonBackgroundGray)
            button.setTitleColor(UIColor(shoutitColor: .fontLighterGray), for: UIControlState())
        }
    }
}
