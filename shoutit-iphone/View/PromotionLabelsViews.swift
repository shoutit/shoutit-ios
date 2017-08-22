//
//  PromotionLabelsViews.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class PromotionLabelsViews: UIView {
    
    @IBOutlet weak var placeholderView : UIView?
    @IBOutlet weak var scroll : UIScrollView?
    @IBOutlet weak var shoutTitleLabel: UILabel?
    @IBOutlet weak var pageControl: UIPageControl?
    
    var timer : Timer?
    var currentSlide = 0
    var maxSlides : Int?
    
    func fillWithShout(_ shout: Shout) {
        self.shoutTitleLabel?.text = shout.title
    }
    
    func presentPromotionLabels(_ labels: [PromotionLabel]) {
        
        if Platform.isRTL {
            self.pageControl?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        } else {
            self.pageControl?.transform = CGAffineTransform.identity
        }
        
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
                NSLayoutConstraint(item: view, attribute: (Platform.isRTL ? .trailing : .leading), relatedBy: .equal, toItem: self.scroll, attribute: (Platform.isRTL ? .trailing : .leading), multiplier: 1.0, constant: Platform.isRTL ? -50 : 50).isActive = true
            } else {
                NSLayoutConstraint(item: view, attribute: (Platform.isRTL ? .trailing : .leading), relatedBy: .equal, toItem: lastView, attribute: (Platform.isRTL ? .leading : .trailing), multiplier: 1.0, constant: Platform.isRTL ? -100 : 100).isActive = true
            }
            
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: self.scroll, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.scroll, attribute: .width, multiplier: 1.0, constant: -100).isActive = true
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.scroll, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
           
            lastView = view
        }
        
        self.setNeedsDisplay()
        
        if Platform.isRTL {
            currentSlide = labels.count - 1
            self.scroll?.contentOffset = CGPoint(x: CGFloat((self.scroll?.frame.width ?? 0) * CGFloat(labels.count - 1)), y: CGFloat(0.0))
        } else {
            currentSlide = 0
        }
        
        self.scroll?.contentSize = CGSize(width: CGFloat((self.scroll?.frame.width ?? 0) * CGFloat(labels.count)), height: self.scroll?.frame.height ?? 0)
        
        startAnimating()
    }
    
    func promotionLabelView(_ promotionLabel: PromotionLabel) -> PromotionLabelView {
        let promotionView = PromotionLabelView.instanceFromNib()
        
        promotionView.bindWithPromotionLabel(promotionLabel)
        
        return promotionView
    }
    
    func hidePlaceholderView() {
        placeholderView?.isHidden = true
    }
    
    func showPlaceholderView() {
        placeholderView?.isHidden = false
    }

    func skipToNextSlide() {
        currentSlide = currentSlide + 1
        
        if currentSlide >= maxSlides {
            currentSlide = 0
        }
        
        let offset : CGFloat = (self.scroll?.frame.width ?? 0) * CGFloat(currentSlide)
        self.scroll?.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    func skipToPreviousSlide() {
        currentSlide = currentSlide - 1
        
        if currentSlide < 0 {
            currentSlide = maxSlides != nil ? maxSlides! - 1 : 0
        }
        
        let offset : CGFloat = (self.scroll?.frame.width ?? 0) * CGFloat(currentSlide)
        self.scroll?.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}

extension PromotionLabelsViews : UIScrollViewDelegate {
    func startAnimating() {
        stopAnimating()
        
        
        self.scroll?.delegate = self
        
        if Platform.isRTL {
            timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(skipToPreviousSlide), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(skipToNextSlide), userInfo: nil, repeats: true)
        }
    }
    
    func stopAnimating() {
        self.scroll?.delegate = nil
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.frame.size.width
        let page = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
        
        self.pageControl?.currentPage = page
    }
    
}
