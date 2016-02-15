//
//  ProfileCollectionViewLayoutAttributes.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var scaleFactor: CGFloat = 1
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ProfileCollectionViewLayoutAttributes
        copy.scaleFactor = scaleFactor
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        guard super.isEqual(object) else {
            return false
        }
        
        guard let attributes = object as? ProfileCollectionViewLayoutAttributes else {
            return false
        }
        
        return scaleFactor == attributes.scaleFactor
    }
}