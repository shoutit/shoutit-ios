//
//  ShoutsCollectionViewLayoutAttributes.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutsCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var mode: ShoutsCollectionViewCell.Mode = .regular
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! ShoutsCollectionViewLayoutAttributes
        copy.mode = mode
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        guard super.isEqual(object) else {
            return false
        }
        
        guard let attributes = object as? ShoutsCollectionViewLayoutAttributes else {
            return false
        }
        
        return mode == attributes.mode
    }
}
