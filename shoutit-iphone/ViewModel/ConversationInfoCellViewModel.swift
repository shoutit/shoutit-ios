//
//  ConversationInfoCellViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 20.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum ConversationInfoCellViewModel {
    case shouts
    case media
    case addMember
    case participants
    case blocked
    case reportChat
    case exitChat
    
    func reuseIdentifier() -> String {
        
        let addButtonCellIdentifier = "ChatInfoAddButtonCell"
        let destructiveButtonCellIdentifier = "ChatInfoDescructiveButtonCell"
        let infoCellIdentifier = "ChatInfoCell"
        
        switch self {
        case .reportChat, .exitChat:
            return destructiveButtonCellIdentifier
        case .shouts, .media, .participants, .blocked:
            return infoCellIdentifier
        case .addMember:
            return addButtonCellIdentifier
        }
    }
    
    func title() -> String {
        switch self {
        case .shouts: return NSLocalizedString("Shouts", comment: "Conversation Info Screen Cell Title")
        case .media: return NSLocalizedString("Media", comment: "Conversation Info Screen Cell Title")
        case .addMember: return NSLocalizedString("Add Member", comment: "Conversation Info Screen Cell Title")
        case .participants: return NSLocalizedString("Participants", comment: "Conversation Info Screen Cell Title")
        case .blocked: return NSLocalizedString("Blocked", comment: "Conversation Info Screen Cell Title")
        case .reportChat: return NSLocalizedString("Report Chat", comment: "Conversation Info Screen Cell Title")
        case .exitChat: return NSLocalizedString("Exit Chat", comment: "Conversation Info Screen Cell Title")
        }
    }
    
    func detailTextWithConversation(_ conversation: Conversation) -> String? {
        switch self {
        case .shouts: return String(conversation.attachmentCount.shout)
        case .media: return String(conversation.attachmentCount.media)
        case .participants: return String(conversation.users?.count ?? 0)
        case .blocked: return String(conversation.blocked?.count ?? 0)
        default: return nil
        }
    }
}
