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
    
    fileprivate var keyboardOffset: CGFloat? {
        get { return objc_getAssociatedObject(self, &keyboardOffsetAssociatedObjectKey) as? CGFloat }
        set(newValue) { objc_setAssociatedObject(self, &keyboardOffsetAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    fileprivate var progressHUD: MBProgressHUD? {
        get { return objc_getAssociatedObject(self, &progressHUDAssociatedObjectKey) as? MBProgressHUD }
        set(newValue) { objc_setAssociatedObject(self, &progressHUDAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func setupKeyboardOffsetNotifcationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.handleKyboardWillShowByModifyingKeyboardOffsetValue(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.handleKeyboardWillHideByModifyingKeyboardOffsetValue(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKyboardWillShowByModifyingKeyboardOffsetValue(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        self.keyboardOffset = keyboardFrame?.height
    }
    
    func handleKeyboardWillHideByModifyingKeyboardOffsetValue(_ notification: Notification) {
        self.keyboardOffset = 0
    }
    
    public func showProgressHUD(_ animated: Bool = true) {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        guard let keyboardHeight = keyboardOffset else {
            return
        }
        let viewCenter = view.bounds.midY
        let viewMinusKeyboardCenter = view.bounds.minY + (view.bounds.height - keyboardHeight) * 0.5
        hud.yOffset = viewMinusKeyboardCenter - viewCenter
    }
    
    public func hideProgressHUD(_ animated: Bool = true) {
        MBProgressHUD.hideAllHUDs(for: view, animated: animated)
    }
}
