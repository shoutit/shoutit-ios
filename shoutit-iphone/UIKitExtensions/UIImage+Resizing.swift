//
//  UIImage+Resizing.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        if newWidth > image.size.width {
            return image
        }
        
        let scale = newWidth / image.size.width
        
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        var newImage : UIImage? = nil
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func dataRepresentation() -> NSData? {
        let resizedImage = UIImage.resizeImage(self, newWidth: MediaAttachment.maximumImageWidth)
        
        return UIImageJPEGRepresentation(resizedImage, 0.7)
    }
}