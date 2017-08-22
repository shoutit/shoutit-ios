//
//  FilterDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol FilterDisplayable {
    func showFiltersWithState(_ state: FiltersState, completionBlock: ((FiltersState) -> Void)?) -> Void
}

extension FlowController : FilterDisplayable {
    
    func showFiltersWithState(_ state: FiltersState, completionBlock: ((FiltersState) -> Void)?) {
        let viewController = Wireframe.filtersViewController()
        viewController.viewModel = FiltersViewModel(filtersState: state)
        viewController.completionBlock = completionBlock
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBarHidden = true
        nav.transitioningDelegate = filterTransition
        nav.modalPresentationStyle = .Custom
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
