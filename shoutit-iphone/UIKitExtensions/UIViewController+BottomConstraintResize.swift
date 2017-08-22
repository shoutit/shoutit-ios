//
//  UIViewController+BottomConstraintResize.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

private var constraintKey : UInt8 = 0

extension UIViewController {
    
    public func setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(_ constraint: NSLayoutConstraint) {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.handleKyboardWillShowByModifyingBottomLayoutGuideConstraint(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.handleKeyboardWillHideByModifyingBottomLayoutGuideConstraint(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        bottomLayoutGuideConstraint = constraint
    }
    
    fileprivate var bottomLayoutGuideConstraint: NSLayoutConstraint! {
        get {
            return objc_getAssociatedObject(self, &constraintKey) as? NSLayoutConstraint
        }
        set(newValue) {
            objc_setAssociatedObject(self, &constraintKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func handleKyboardWillShowByModifyingBottomLayoutGuideConstraint(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve!) | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        bottomLayoutGuideConstraint.constant = keyboardFrameConvertedToViewFrame.height
        
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
        }
    }
    
    func handleKeyboardWillHideByModifyingBottomLayoutGuideConstraint(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve!) | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        bottomLayoutGuideConstraint.constant = 0
        
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
        }
    }
}
