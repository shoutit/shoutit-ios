//
//  ShoutDetailImagesPageViewControllerDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher

class ShoutDetailImagesPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    let viewModel: ShoutDetailViewModel
    
    init(viewModel: ShoutDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func viewControllers() -> [PhotoBrowserPhotoViewController] {
        if let first = viewModel.imagesViewModels.first {
            let controller = viewControllerWithViewModel(first)
            return [controller]
        }
        return []
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let controller = viewController as? PhotoBrowserPhotoViewController else {
            return nil
        }
        
        if controller.index >= viewModel.imagesViewModels.count - 1 {
            return nil
        }
        
        let controllerViewModel = viewModel.imagesViewModels[controller.index + 1]
        let nextController = viewControllerWithViewModel(controllerViewModel)
        nextController.index = controller.index + 1
        
        return nextController
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let controller = viewController as? PhotoBrowserPhotoViewController else {
            return nil
        }
        
        if controller.index <= 0 {
            return nil
        }
        
        let controllerViewModel = viewModel.imagesViewModels[controller.index - 1]
        let nextController = viewControllerWithViewModel(controllerViewModel)
        nextController.index = controller.index - 1
        
        return nextController
    }
    
    // MARK: - Helpers
    
    private func viewControllerWithViewModel(viewModel: ShoutDetailShoutImageViewModel) -> PhotoBrowserPhotoViewController {
        
        let viewController = Wireframe.photoBrowserPhotoViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
}
