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
        switch state.value {
        case .Refreshing(let cells, _):
            return cells
        case .LoadingMore(let cells, _, _):
            return cells
        case .Loaded(let cells, _, _):
            return cells
        case .LoadedAllContent(let cells, _):
            return cells
        default:
            return nil
        }
    }
}
