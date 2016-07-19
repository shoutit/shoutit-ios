//
//  MenuCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class MenuCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView?
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint?
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustSeparatorHeight()
    }
    
    func bindWith(item: NavigationItem!, current: Bool) {
        iconImageView?.image = NavigationItem.icon(item)()
        titleLabel.text = NavigationItem.title(item)()
        backgroundColor = current ? UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1) : UIColor.whiteColor()
    }
    
    func setSeparatorVisible(visible: Bool) {
        bottomSeparator?.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(visible ? 0.4 : 0.0)
    }
    
    private func adjustSeparatorHeight() {
        bottomSeparatorHeight?.constant = 1.0/UIScreen.mainScreen().scale
        layoutIfNeeded()
    }
    
    func setBadgeNumber(badgeNumber: Int) {
        badgeLabel.hidden = badgeNumber < 1
        badgeLabel.text = NumberFormatters.badgeCountStringWithNumber(badgeNumber)
    }
}
