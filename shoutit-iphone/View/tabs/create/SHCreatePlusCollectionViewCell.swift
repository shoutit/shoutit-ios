//
//  SHCreatePlusCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHCreatePlusCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plusImageView: UIImageView!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let frame = self.plusImageView.frame
            let point = touch.locationInView(self.plusImageView.superview)
            
            if CGRectContainsPoint(frame, point) {
                let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.5));
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.plusImageView.transform = CGAffineTransformScale(transform, 1.5, 1.5)
                    }, completion: nil)
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let frame = self.plusImageView.frame
            let point = touch.locationInView(self.plusImageView.superview)
            
            if(CGRectContainsPoint(frame, point)) {
                let transform = CGAffineTransformMakeRotation(0)
                UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { () -> Void in
                    self.plusImageView.transform = CGAffineTransformScale(transform, 1, 1)
                    }, completion: nil)
            }
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        let transform = CGAffineTransformMakeRotation(0)
        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [.CurveEaseInOut], animations: { () -> Void in
            self.plusImageView.transform = CGAffineTransformScale(transform, 1, 1)
            }, completion: nil)
        super.touchesCancelled(touches, withEvent: event)
    }
}
