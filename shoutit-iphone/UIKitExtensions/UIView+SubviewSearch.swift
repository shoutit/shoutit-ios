//
//  UIView+SubviewSearch.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIView {
    
    func searchForTextField() -> UITextField? {
        if let view = self as? UITextField {
            return view
        }
        
        for subview in self.subviews {
            if let textField = subview.searchForTextField() {
                return textField
            }
        }
        
        return nil
    }
}
