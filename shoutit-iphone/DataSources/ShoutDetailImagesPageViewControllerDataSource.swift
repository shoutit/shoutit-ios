//
//  ShoutDetailImagesPageViewControllerDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutDetailImagesPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    let viewModel: ShoutDetailViewModel
    
    init(viewModel: ShoutDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        fatalError()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        fatalError()
    }
}
