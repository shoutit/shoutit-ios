//
//  FilterDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol FilterDisplayable {
    var filterTransition: FilterTransition {get}
    func showFilters() -> Void
}

extension FilterDisplayable where Self: FlowController {
    
    func showFilters() {
        let viewController = Wireframe.filtersViewController()
        viewController.viewModel = FiltersViewModel()
        viewController.transitioningDelegate = filterTransition
        viewController.modalPresentationStyle = .Custom
        navigationController.presentViewController(viewController, animated: true, completion: nil)
    }
}
