//
//  PagedViewModelState.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

enum PagedViewModelState <CellViewModelType, PageIndexType, ItemType: Decodable where ItemType.DecodedType == ItemType> {
    case Idle
    case Loading
    case Loaded(cells: [CellViewModelType], page: PageIndexType, lastPageResults: PagedResults<ItemType>)
    case LoadingMore(cells: [CellViewModelType], currentPage: PageIndexType, loadingPage: PageIndexType)
    case Refreshing(cells: [CellViewModelType], page: PageIndexType)
    case LoadedAllContent(cells: [CellViewModelType], page: PageIndexType)
    case NoContent
    case Error(ErrorType)
    
    func getCellViewModels() -> [CellViewModelType]? {
        switch self {
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

