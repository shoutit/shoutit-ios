//
//  MenuCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class MenuCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView?
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint?
    
    func bindWith(item: NavigationItem!, current: Bool) {
        self.iconImageView?.image = NavigationItem.icon(item)()
        self.titleLabel.text = NavigationItem.title(item)()
        
        self.bottomSeparatorHeight?.constant = 1.0/UIScreen.mainScreen().scale
        self.backgroundColor = current ? UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1) : UIColor.whiteColor()
        self.layoutIfNeeded()
        
        setSeparatorVisible(item == .Chats || current)
        
//        self.accessoryType = ((item == .InviteFriends) ? .DetailButton : .None)
//        self.tintColor = UIColor(shoutitColor: .PrimaryGreen)
    }
    
    func setSeparatorVisible(visible: Bool) {
        self.bottomSeparator?.backgroundColor = visible ? UIColor.lightGrayColor().colorWithAlphaComponent(0.4) : UIColor.clearColor()
    }
}
