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
        case facebook
        case twitter
        
        var title: String {
            switch self {
            case .facebook: return NSLocalizedString("Facebook", comment: "Create public chat cell title")
            case .twitter: return NSLocalizedString("Twitter", comment: "Create public chat cell title")
            }
        }
    }
    
    case selectable(option: SelectionOption, selected: Bool)
    case location(location: Address)
}
