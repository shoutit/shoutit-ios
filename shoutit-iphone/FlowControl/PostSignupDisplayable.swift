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

extension PostSignupDisplayable where Self: FlowController {
    
    func showPostSignupInterests() {
        let postSignupController = Wireframe.postSignupInterestsViewController()
        postSignupController.viewModel = PostSignupInterestsViewModel()
        navigationController.showViewController(postSignupController, sender: nil)
    }
    
    func showPostSignupSuggestions() {
        
    }
}