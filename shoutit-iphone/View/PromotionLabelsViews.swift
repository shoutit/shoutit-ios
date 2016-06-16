//
//  PromotionLabelsViews.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class PromotionLabelsViews: UIView {
    
    @IBOutlet weak var placeholderView : UIView?
    @IBOutlet weak var scroll : UIScrollView?
    @IBOutlet weak var shoutTitleLabel: UILabel?
    
    func fillWithShout(shout: Shout) {
        self.shoutTitleLabel?.text = shout.title
    }
    
    func presentPromotionLabels(labels: [PromotionLabel]) {
        
        scroll?.subviews.each { (view) in
            view.removeFromSuperview()
        }
        
        if labels.count > 0 {
            hidePlaceholderView()
        } else {
            showPlaceholderView()
        }
        
        
        var lastView : UIView?
        
        labels.each { (label) in
            let view = promotionLabelView(label)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            self.scroll?.addSubview(view)
            
            if lastView == nil {
                NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self.scroll, attribute: .Leading, multiplier: 1.0, constant: 50).active = true
            } else {
                NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: lastView, attribute: .Trailing, multiplier: 1.0, constant: 100).active = true
            }
            
            NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: self.scroll, attribute: .Height, multiplier: 1.0, constant: 0).active = true
            NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self.scroll, attribute: .Width, multiplier: 1.0, constant: -100).active = true
            NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self.scroll, attribute: .Top, multiplier: 1.0, constant: 0).active = true
           
            lastView = view
        }
        
        self.setNeedsDisplay()
        
        self.scroll?.contentSize = CGSize(width: CGFloat((self.scroll?.frame.width ?? 0) * CGFloat(labels.count)), height: self.scroll?.frame.height ?? 0)
    }
    
    func promotionLabelView(promotionLabel: PromotionLabel) -> PromotionLabelView {
        let promotionView = PromotionLabelView.instanceFromNib()
        
        promotionView.bindWithPromotionLabel(promotionLabel)
        
        return promotionView
    }
    
    func hidePlaceholderView() {
        placeholderView?.hidden = true
    }
    
    func showPlaceholderView() {
        placeholderView?.hidden = false
    }

}
