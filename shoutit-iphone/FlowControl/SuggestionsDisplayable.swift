//
//  SuggestionsDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol SuggestionsDisplayable {
    func showSuggestedUsers()
    func showSuggestedPages()
}

extension FlowController : SuggestionsDisplayable {
    
    func showSuggestedUsers() {
        let controller = Wireframe.suggestionsController()
        
        controller.viewModel = PostSignupSuggestionViewModel()
        
        navigationController.showViewController(controller, sender: nil)
        
    }
    func showSuggestedPages() {
        let controller = Wireframe.suggestionsController()
        
        controller.viewModel = PostSignupSuggestionViewModel()

        navigationController.showViewController(controller, sender: nil)
    }
}
