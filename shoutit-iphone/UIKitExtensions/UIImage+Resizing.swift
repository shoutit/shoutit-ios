//
//  UIImage+Resizing.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        if newWidth > image.size.width {
            return image
        }
        
        let scale = newWidth / image.size.width
        
        let newHeight = image.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)

        let screenScale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        var newImage : UIImage? = nil
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func dataRepresentation() -> Data? {
        let resizedImage = UIImage.resizeImage(self, newWidth: MediaAttachment.maximumImageWidth)
        
        return UIImageJPEGRepresentation(resizedImage, 0.7)
    }
}
