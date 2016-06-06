//
//  UIViewController+ProgressHUD.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD

private var keyboardOffsetAssociatedObjectKey : UInt8 = 0
private var progressHUDAssociatedObjectKey: UInt8 = 1

extension UIViewController {
    
    private var keyboardOffset: CGFloat? {
        get { return objc_getAssociatedObject(self, &keyboardOffsetAssociatedObjectKey) as? CGFloat }
        set(newValue) { objc_setAssociatedObject(self, &keyboardOffsetAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var progressHUD: MBProgressHUD? {
        get { return objc_getAssociatedObject(self, &progressHUDAssociatedObjectKey) as? MBProgressHUD }
        set(newValue) { objc_setAssociatedObject(self, &progressHUDAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func setupKeyboardOffsetNotifcationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.handleKyboardWillShowByModifyingKeyboardOffsetValue(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.handleKeyboardWillHideByModifyingKeyboardOffsetValue(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKyboardWillShowByModifyingKeyboardOffsetValue(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        self.keyboardOffset = keyboardFrame?.height
    }
    
    func handleKeyboardWillHideByModifyingKeyboardOffsetValue(notification: NSNotification) {
        self.keyboardOffset = 0
    }
    
    public func showProgressHUD(animated: Bool = true) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        guard let keyboardHeight = keyboardOffset else {
            return
        }
        let viewCenter = view.bounds.midY
        let viewMinusKeyboardCenter = view.bounds.minY + (view.bounds.height - keyboardHeight) * 0.5
        hud.yOffset = Float(viewMinusKeyboardCenter - viewCenter)
    }
    
    public func hideProgressHUD(animated: Bool = true) {
        MBProgressHUD.hideAllHUDsForView(view, animated: animated)
    }
}