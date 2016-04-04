//
//  UIViewController+Error.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ObjectiveC

var vc_associatedTimerObjectHandle: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0)
var vc_associatedErrorBarViewObjectHandle: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 1)

extension UIViewController {
    
    // MARK: - Private vars
    
    private var barAnimationDuration: NSTimeInterval {
        return 0.5
    }
    
    private var barTimer: NSTimer? {
        get {
            return objc_getAssociatedObject(self, vc_associatedTimerObjectHandle) as? NSTimer
        }
        
        set {
            objc_setAssociatedObject(self, vc_associatedTimerObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var barView: AlertBarView {
        get {
            if let barView = objc_getAssociatedObject(self, vc_associatedErrorBarViewObjectHandle) as? AlertBarView {
                return barView
            }
            let barView = NSBundle.mainBundle().loadNibNamed("AlertBarView", owner: nil, options: nil)[0] as! AlertBarView
            
            // position views
            barView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(barView)
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: [], metrics: nil, views: ["bar" : barView]))
            
            view.addConstraint(NSLayoutConstraint(item: barView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: hasFakeNavigationBar() ? 44 : 0))
            barView.addConstraint(NSLayoutConstraint(item: barView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))
            
            // hide
            barView.alpha = 0.0
            barView.hidden = true
            
            // configure tap gesture recognizer
            barView.tapGestureRecognizer.addTarget(self, action: #selector(UIViewController.hideErrorMessage))
            
            // save
            objc_setAssociatedObject(self, vc_associatedErrorBarViewObjectHandle, barView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return barView
        }
    }
    
    // MARK: - Public API
    
    func showSuccessMessage(message: String) {
        barView.setAppearanceForAlertType(.Success)
        showBarWithMessage(message)
    }
    
    func showError(error: ErrorType) {
        showErrorMessage(error.sh_message)
    }
    
    func showErrorMessage(message: String) {
        barView.setAppearanceForAlertType(.Error)
        showBarWithMessage(message)
    }
    
    func hideErrorMessage() {
        barTimer?.invalidate()
        barTimer = nil
        barView.layer.removeAllAnimations()
        UIView.animateWithDuration(barAnimationDuration, animations: {[weak self] in
                                    self?.barView.alpha = 0.0
            },
                                   completion: {[weak self] (finished) in
                                    self?.barView.hidden = true
            })
    }
    
    private func showBarWithMessage(message: String) {
        barView.errorMessageLabel.text = message
        barView.hidden = false
        barView.layer.removeAllAnimations()
        UIView.animateWithDuration(barAnimationDuration) {[weak self] in
            self?.barView.alpha = 1.0
        }
        barTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(UIViewController.hideErrorMessage), userInfo: nil, repeats: false)

    }
}
