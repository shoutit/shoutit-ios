//
//  PostSignupDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol PostSignupDisplayable {
    func showPostSignupInterests() -> Void
    func showPostSignupSuggestions() -> Void
}

extension LoginFlowController : PostSignupDisplayable {
    
    func showPostSignupInterests() {
        let postSignupController = Wireframe.postSignupInterestsViewController()
        postSignupController.viewModel = PostSignupInterestsViewModel()
        postSignupController.loginDelegate = self
        navigationController.show(postSignupController, sender: nil)
    }
    
    func showPostSignupSuggestions() {
        let postSignupController = Wireframe.postSignupSuggestionsViewController()
        postSignupController.viewModel = PostSignupSuggestionViewModel()
        postSignupController.loginDelegate = self
        navigationController.show(postSignupController, sender: nil)
    }
}

extension FlowController {
    func showSuggestions() {
        let postSignupController = Wireframe.postSignupSuggestionsViewController()
        postSignupController.viewModel = PostSignupSuggestionViewModel()
        postSignupController.flowSimpleDelegate = self
        navigationController.show(postSignupController, sender: nil)
    }
    
    func presentInterests() {
        let postSignupController = Wireframe.postSignupInterestsViewController()
        postSignupController.viewModel = PostSignupInterestsViewModel()
        postSignupController.flowSimpleDelegate = self
        
        navigationController.present(postSignupController, animated: true, completion: nil)
    }
    
    func presentSuggestions() {
        let postSignupController = Wireframe.postSignupSuggestionsViewController()
        postSignupController.viewModel = PostSignupSuggestionViewModel()
        postSignupController.flowSimpleDelegate = self

        navigationController.present(postSignupController, animated: true, completion: nil)
    }
}
