//
//  SearchShoutsResultsShoutsHeaderSupplementeryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class SearchShoutsResultsShoutsHeaderSupplementeryView: UICollectionReusableView {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var layoutButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}