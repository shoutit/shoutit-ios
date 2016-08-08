//
//  StaticPageDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol StaticPageDisplayable {
    func showStaticPage(url: NSURL) -> Void
}

extension FlowController : StaticPageDisplayable {
    
    func showStaticPage(url: NSURL) -> Void {
        let controller = Wireframe.staticPageViewController()
    
        controller.urlToLoad = url
        controller.flowDelegate = self
        
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
