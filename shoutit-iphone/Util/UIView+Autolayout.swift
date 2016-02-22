//
//  UIView+Autolayout.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIView {
    
    func removeContraintsForView(view: UIView!) {
        for constraint in self.constraints {
            var shouldBeRemoved = false
            
            if let firstItem = constraint.firstItem as? NSObject {
                if firstItem == view {
                    shouldBeRemoved = true
                }
            }
            
            if let secondItem = constraint.secondItem as? NSObject {
                if secondItem == view {
                    shouldBeRemoved = true
                }
            }
            
            
            if shouldBeRemoved {
                self.removeConstraint(constraint)
            }
        }
        
        for constraint in view.constraints {
            if let firstItem = constraint.firstItem as? NSObject {
                if firstItem == view && constraint.secondItem == nil {
                    view.removeConstraint(constraint)
                }
            }
        }
    }
    
}