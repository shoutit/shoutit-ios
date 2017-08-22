//
//  StaticPageDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol StaticPageDisplayable {
    func showStaticPage(_ url: URL, title: String?) -> Void
}

extension FlowController : StaticPageDisplayable {
    
    func showStaticPage(_ url: URL, title: String?) -> Void {
        let controller = Wireframe.staticPageViewController()
    
        controller.urlToLoad = url
        controller.flowDelegate = self
        controller.titleToShow = title
        
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.present(nav, animated: true, completion: nil)
        
    }
}
