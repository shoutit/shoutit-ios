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
    @IBOutlet weak var pageControl: UIPageControl?
    
    var timer : NSTimer?
    var currentSlide = 0
    var maxSlides : Int?
    
    func fillWithShout(shout: Shout) {
        self.shoutTitleLabel?.text = shout.title
    }
    
    func presentPromotionLabels(labels: [PromotionLabel]) {
        
        scroll?.subviews.each { (view) in
            view.removeFromSuperview()
        }

        
        
        maxSlides = labels.count
        
        if labels.count > 0 {
            hidePlaceholderView()
            startAnimating()
            pageControl?.numberOfPages = labels.count
        } else {
            pageControl?.numberOfPages = 0
            showPlaceholderView()
            stopAnimating()
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
        
        startAnimating()
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

    func skipToNextSlide() {
        currentSlide = currentSlide + 1
        
        if currentSlide >= maxSlides {
            currentSlide = 0
        }
        
        let offset : CGFloat = (self.scroll?.frame.width ?? 0) * CGFloat(currentSlide)
        self.scroll?.setContentOffset(CGPointMake(offset, 0), animated: true)
    }
}

extension PromotionLabelsViews : UIScrollViewDelegate {
    func startAnimating() {
        stopAnimating()
        
        self.scroll?.delegate = self
        timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(skipToNextSlide), userInfo: nil, repeats: true)
    }
    
    func stopAnimating() {
        self.scroll?.delegate = nil
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let width = scrollView.frame.size.width
        let page = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
        
        self.pageControl?.currentPage = page
    }
    
}
