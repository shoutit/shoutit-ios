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
    
    public func setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(constraint: NSLayoutConstraint) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        bottomLayoutGuideConstraint = constraint
    }
    
    private var bottomLayoutGuideConstraint: NSLayoutConstraint! {
        get {
            return objc_getAssociatedObject(self, &constraintKey) as? NSLayoutConstraint
        }
        set(newValue) {
            objc_setAssociatedObject(self, &constraintKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let keyboardFrameConvertedToViewFrame = view.convertRect(keyboardFrame!, fromView: nil)
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve) | UIViewAnimationOptions.BeginFromCurrentState.rawValue)
        bottomLayoutGuideConstraint.constant = keyboardFrameConvertedToViewFrame.height
        
        UIView.animateWithDuration(animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve) | UIViewAnimationOptions.BeginFromCurrentState.rawValue)
        bottomLayoutGuideConstraint.constant = 0
        
        UIView.animateWithDuration(animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
        }
    }
}
