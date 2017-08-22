//
//  PhotoBrowserPageViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class PhotoBrowserPageViewController: UIPageViewController {
    
    var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add page control
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: pageControl, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: pageControl, attribute: .bottom, multiplier: 1.0, constant: 10.0))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.bringSubview(toFront: pageControl)
    }
}
