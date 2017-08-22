//
//  ReusableView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
