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

extension PostSignupDisplayable where Self: FlowController, Self: PostSignupInterestsViewControllerFlowDelegate, Self: PostSignupSuggestionViewControllerFlowDelegate {
    
    func showPostSignupInterests() {
        let postSignupController = Wireframe.postSignupInterestsViewController()
        postSignupController.viewModel = PostSignupInterestsViewModel()
        postSignupController.flowDelegate = self
        navigationController.showViewController(postSignupController, sender: nil)
    }
    
    func showPostSignupSuggestions() {
        let postSignupController = Wireframe.postSignupSuggestionsViewController()
        postSignupController.viewModel = PostSignupSuggestionViewModel()
        postSignupController.flowDelegate = self
        navigationController.showViewController(postSignupController, sender: nil)
    }
}