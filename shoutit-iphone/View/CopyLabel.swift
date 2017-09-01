//
//  CopyLabel.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//


import UIKit

class CopyLabel: ResponsiveLabel {
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    func showMenu(_ sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(NSObject.copy) {
            return true
        }
        return false
    }
    
    
}
