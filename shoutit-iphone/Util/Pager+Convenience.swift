//
//  Pager+Convenience.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension Pager {
    
    func getCellViewModels() -> [CellViewModelType]? {
        return state.value.getCellViewModels()
    }
}
