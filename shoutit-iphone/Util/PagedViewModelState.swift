//
//  PagedViewModelState.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable
import ShoutitKit

enum PagedViewModelState <CellViewModelType, PageIndexType, ItemType: JSONCodable> {
    case idle
    case loading
    case loaded(cells: [CellViewModelType], page: PageIndexType, lastPageResults: PagedResults<ItemType>)
    case loadingMore(cells: [CellViewModelType], currentPage: PageIndexType, loadingPage: PageIndexType)
    case refreshing(cells: [CellViewModelType], page: PageIndexType)
    case loadedAllContent(cells: [CellViewModelType], page: PageIndexType)
    case noContent
    case error(Error)
    
    func getCellViewModels() -> [CellViewModelType]? {
        switch self {
        case .refreshing(let cells, _):
            return cells
        case .loadingMore(let cells, _, _):
            return cells
        case .loaded(let cells, _, _):
            return cells
        case .loadedAllContent(let cells, _):
            return cells
        default:
            return nil
        }
    }
}

