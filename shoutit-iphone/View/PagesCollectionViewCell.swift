//
//  ProfileCollectionPagesCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class PagesCollectionViewCell: UICollectionViewCell {
    
    var reuseDisposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
