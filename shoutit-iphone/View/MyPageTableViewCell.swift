//
//  MyPageTableViewCell.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class MyPageTableViewCell: UITableViewCell {
    
    private(set) var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detaiLabel: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!
    @IBOutlet weak var badgeLabel: CustomUILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorViewHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        reuseDisposeBag = DisposeBag()
    }
}

extension MyPageTableViewCell: ReusableView, NibLoadableView {}
