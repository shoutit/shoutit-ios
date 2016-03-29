//
//  PagedViewModelState.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum PagedViewModelState <T> {
    case Idle
    case Loading
    case Loaded(cells: [T], page: Int)
    case LoadingMore(cells: [T], currentPage: Int, loadingPage: Int)
    case LoadedAllContent(cells: [T], page: Int)
    case NoContent
    case Error(ErrorType)
}

