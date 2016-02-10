//
//  PostSignupSuggestionBaseTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class PostSignupSuggestionBaseTableViewCell: UITableViewCell {
    
    var roundedTop: Bool = true
    var roundedBottom: Bool = true
    
    func setupCellForRoundedTop(top: Bool, roundedBottom bottom: Bool) {
        
        // the shadow rect determines the area in which the shadow gets drawn
        var shadowRect = CGRectInset(bounds, 0, -10);
        if top {
            shadowRect.origin.y += 10
        } else if bottom {
            shadowRect.size.height -= 10;
        }
        
        // the mask rect ensures that the shadow doesn't bleed into other table cells
        var maskRect = CGRectInset(bounds, -20, 0);
        if top {
            maskRect.origin.y -= 10;
            maskRect.size.height += 10;
        } else if bottom {
            maskRect.size.height += 10;
        }
        
        // now configure the background view layer with the shadow
        let layer = self.layer
        layer.shadowColor = UIColor.grayColor().CGColor;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 3;
        layer.shadowOpacity = 0.75;
        layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).CGPath
        layer.masksToBounds = false;
        
        // and finally add the shadow mask
        let maskLayer = CAShapeLayer()
        let size = CGSize(width: 22, height: 22)
        
        if top && bottom {
            layer.cornerRadius = 22;
        } else if top {
            maskLayer.path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: size).CGPath
        } else if bottom {
            maskLayer.path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: size).CGPath
        } else {
            maskLayer.path = UIBezierPath(rect: maskRect).CGPath
        }
        
        layer.mask = maskLayer;
    }
    
//    func setupCellForRoundedTop(top: Bool, roundedBottom bottom: Bool) {
//        
//        let shape = CAShapeLayer()
//        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        let size = CGSize(width: 22, height: 22)
//        
//        if top && bottom {
//            layer.cornerRadius = 22;
//            layer.masksToBounds = true;
//        } else if top {
//            shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: size).CGPath
//            layer.mask = shape;
//            layer.masksToBounds = true;
//        } else if bottom {
//            shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: size).CGPath
//            layer.mask = shape;
//            layer.masksToBounds = true;
//        }
//        
//        // the shadow rect determines the area in which the shadow gets drawn
//        var shadowRect = CGRectInset(bounds, 0, -10);
//        if first {
//            shadowRect.origin.y += 10
//        } else if last {
//            shadowRect.size.height -= 10;
//        }
//        
//        // the mask rect ensures that the shadow doesn't bleed into other table cells
//        var maskRect = CGRectInset(bounds, -20, 0);
//        if first {
//            maskRect.origin.y -= 10;
//            maskRect.size.height += 10;
//        } else if last {
//            maskRect.size.height += 10;
//        }
//        
//        // now configure the background view layer with the shadow
//        let layer = self.layer
//        layer.shadowColor = UIColor.grayColor().CGColor;
//        layer.shadowOffset = CGSizeMake(0, 0);
//        layer.shadowRadius = 3;
//        layer.shadowOpacity = 0.75;
//        layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).CGPath
//        layer.masksToBounds = false;
//        
//        // and finally add the shadow mask
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = UIBezierPath(rect: maskRect).CGPath
//        layer.mask = maskLayer;
//    }
}