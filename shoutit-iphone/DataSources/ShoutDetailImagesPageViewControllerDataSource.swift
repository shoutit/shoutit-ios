//
//  ShoutDetailImagesPageViewControllerDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

final class ShoutDetailImagesPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    unowned let controller: ShoutDetailTableViewController
    
    let showDetailOfMedia = PublishSubject<ShoutDetailShoutImageViewModel>()
    
    var viewModel: ShoutDetailViewModel {
        return controller.viewModel
    }
    
    init(controller: ShoutDetailTableViewController) {
        self.controller = controller
        super.init()
    }
    
    func firstViewController() -> PhotoBrowserPhotoViewController? {
        guard let first = viewModel.imagesViewModels.first else {
            return nil
        }
        let controller = viewControllerWithViewModel(first)
        return controller
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
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
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
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
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        guard let controller = pageViewController as? PhotoBrowserPageViewController else {
            assert(false)
            return
        }
        
        guard let currentController = pendingViewControllers.first as? PhotoBrowserPhotoViewController else {
            assert(false)
            return
        }
        
        updatePageControlWithPageViewController(controller, currentController: currentController)
    }
    
    // MARK: - Helpers
    
    private func viewControllerWithViewModel(viewModel: ShoutDetailShoutImageViewModel) -> PhotoBrowserPhotoViewController {
        
        let viewController = Wireframe.photoBrowserPhotoViewController()
        viewController.viewModel = viewModel
        viewController.tapHandler = { (viewModel) in
            self.showDetailOfMedia.onNext(viewModel)
        }
        
        return viewController
    }
    
    func updatePageControlWithPageViewController(pageViewController: PhotoBrowserPageViewController, currentController: PhotoBrowserPhotoViewController?) {
        
        pageViewController.pageControl.numberOfPages = viewModel.imagesViewModels.count
        pageViewController.pageControl.currentPage = currentController?.index ?? 0
    }
}
