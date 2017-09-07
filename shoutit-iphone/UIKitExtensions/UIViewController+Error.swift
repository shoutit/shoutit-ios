//
//  UIViewController+Error.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ObjectiveC

var vc_associatedTimerObjectHandle: UnsafePointer<UInt8>? = UnsafePointer(bitPattern: 0)
var vc_associatedErrorBarViewObjectHandle: UnsafePointer<UInt8>? = UnsafePointer(bitPattern: 1)

extension UIViewController {
    
    // MARK: - Private vars
    
    fileprivate var barAnimationDuration: TimeInterval {
        return 0.5
    }
    
    fileprivate var barTimer: Timer? {
        get {
            return objc_getAssociatedObject(self, vc_associatedTimerObjectHandle) as? Timer
        }
        
        set {
            objc_setAssociatedObject(self, vc_associatedTimerObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var barView: AlertBarView {
        get {
            if let barView = objc_getAssociatedObject(self, vc_associatedErrorBarViewObjectHandle) as? AlertBarView {
                return barView
            }
            let barView = Bundle.main.loadNibNamed("AlertBarView", owner: nil, options: nil)?[0] as! AlertBarView
            barView.translatesAutoresizingMaskIntoConstraints = true
            barView.autoresizingMask = [.flexibleHeight]
            
            // hide
            barView.alpha = 0.0
            barView.isHidden = true
            
            // configure tap gesture recognizer
            barView.tapGestureRecognizer.addTarget(self, action: #selector(UIViewController.hideErrorMessage))
            
            // save
            objc_setAssociatedObject(self, vc_associatedErrorBarViewObjectHandle, barView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return barView
        }
    }
    
    // MARK: - Public API
    
    func showSuccessMessage(_ message: String) {
        barView.setAppearanceForAlertType(.success)
        showBarWithMessage(message)
    }
    
    func showError(_ error: Error) {
        showErrorMessage(error.sh_message)
    }
    
    func showErrorMessage(_ message: String) {
        barView.setAppearanceForAlertType(.error)
        showBarWithMessage(message)
    }
    
    func hideErrorMessage() {
        barTimer?.invalidate()
        barTimer = nil
        barView.layer.removeAllAnimations()
        UIView.animate(withDuration: barAnimationDuration, animations: {[weak self] in
                                    self?.barView.alpha = 0.0
            },
                                   completion: {[weak self] (finished) in
                                    self?.barView.isHidden = true
                                    self?.barView.removeFromSuperview()
            })
    }
    
    fileprivate func showBarWithMessage(_ message: String) {
        barTimer?.invalidate()
        barTimer = nil
        
        barView.errorMessageLabel.text = message
        barView.isHidden = false
        barView.layer.removeAllAnimations()
        
        
        let shouldAddNavBarThreshold = (navigationController != nil && navigationController?.isNavigationBarHidden == false) || hasFakeNavigationBar()
        let y: CGFloat = shouldAddNavBarThreshold ? 64 : 20
        barView.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 40)
        if barView.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(barView)
        }
        
        UIView.animate(withDuration: barAnimationDuration, animations: {[weak self] in
            self?.barView.alpha = 1.0
        }) 
        barTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(UIViewController.hideErrorMessage), userInfo: nil, repeats: false)

    }
}
