//
//  CreatePublicChatCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum CreatePublicChatCellViewModel {
    
    enum SelectionOption {
        case Facebook
        case Twitter
        
        var title: String {
            switch self {
            case .Facebook: return NSLocalizedString("Facebook", comment: "Create public chat cell title")
            case .Twitter: return NSLocalizedString("Twitter", comment: "Create public chat cell title")
            }
        }
    }
    
    case Selectable(option: SelectionOption, selected: Bool)
    case Location(location: Address)
}
