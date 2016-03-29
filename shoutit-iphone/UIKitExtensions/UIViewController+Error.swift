//
//  UIViewController+Error.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ObjectiveC

var vc_associatedTimerObjectHandle: UnsafePointer<UInt8> = nil
var vc_associatedErrorBarViewObjectHandle: UnsafePointer<UInt8> = nil

extension UIViewController {
    
    // MARK: - Private vars
    
    private var errorBarAnimationDuration: NSTimeInterval {
        return 0.5
    }
    
    private var errorTimer: NSTimer? {
        get {
            return objc_getAssociatedObject(self, vc_associatedTimerObjectHandle) as? NSTimer
        }
        
        set {
            objc_setAssociatedObject(self, vc_associatedTimerObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var errorBarView: ErrorAlertBarView {
        get {
            if let barView = objc_getAssociatedObject(self, vc_associatedErrorBarViewObjectHandle) as? ErrorAlertBarView {
                return barView
            }
            let barView = NSBundle.mainBundle().loadNibNamed("ErrorAlertBarView", owner: nil, options: nil)[0] as! ErrorAlertBarView
            
            // position views
            barView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(barView)
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: [], metrics: nil, views: ["bar" : barView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(>=40)", options: [], metrics: nil, views: ["bar" : barView]))
            
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
    
    func showError(error: ErrorType) {
        showErrorMessege(error.sh_message)
    }
    
    func showErrorMessege(message: String) {
        errorBarView.errorMessageLabel.text = message
        errorBarView.hidden = false
        errorBarView.layer.removeAllAnimations()
        UIView.animateWithDuration(errorBarAnimationDuration) {[weak self] in
            self?.errorBarView.alpha = 1.0
        }
        errorTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(UIViewController.hideErrorMessage), userInfo: nil, repeats: false)
    }
    
    func hideErrorMessage() {
        errorTimer?.invalidate()
        errorTimer = nil
        errorBarView.layer.removeAllAnimations()
        UIView.animateWithDuration(errorBarAnimationDuration, animations: {[weak self] in
                                    self?.errorBarView.alpha = 0.0
            },
                                   completion: {[weak self] (finished) in
                                    self?.errorBarView.hidden = true
            })
    }
}
