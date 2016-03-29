//
//  UIView+SubviewSearch.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIView {
    
    func searchForView<T>() -> T? {
        if let view = self as? T {
            return view
        }
        
        for subview in self.subviews {
            if let view: T = subview.searchForView() {
                return view
            }
        }
        
        return nil
    }
}
