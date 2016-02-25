//
//  SearchDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol SearchDisplayable {
    func showSearch() -> Void
}

extension SearchDisplayable where Self: FlowController {
    
    func showSearch() {
        navigationController.notImplemented()
    }
}
