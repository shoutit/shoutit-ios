//
//  SearchSuggestionTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class SearchSuggestionTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var leadingImageView: UIImageView!
    @IBOutlet weak var fillButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    func showLeadingIcon(icon: UIImage?) {
        leadingImageView.image = icon
        leadingImageView.hidden = icon == nil
        labelLeadingConstraint.constant = icon != nil ? 50 : 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingImageView.image = nil
        reuseDisposeBag = DisposeBag()
    }
}
