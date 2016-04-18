//
//  ShoutsCollectionViewLayoutAttributes.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutsCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var mode: ShoutsCollectionViewCell.Mode = .Regular
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ShoutsCollectionViewLayoutAttributes
        copy.mode = mode
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        guard super.isEqual(object) else {
            return false
        }
        
        guard let attributes = object as? ShoutsCollectionViewLayoutAttributes else {
            return false
        }
        
        return mode == attributes.mode
    }
}
