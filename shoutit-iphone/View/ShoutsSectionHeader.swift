//
//  ShoutsSectionHeader.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ShoutsSectionHeader: UICollectionReusableView {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var layoutButton: UIButton!
    
    @IBOutlet weak var subtitleHeightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
    
    func setSubtitleHidden(hidden: Bool) {
        self.subtitleHeightConstraint.constant = hidden ? 5.0 : 15.0
        
        layoutIfNeeded()
    }
}
