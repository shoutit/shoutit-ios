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
    case Shouts
    case Media
    case AddMember
    case Participants
    case Blocked
    case ReportChat
    case ExitChat
    
    func reuseIdentifier() -> String {
        
        let addButtonCellIdentifier = "ChatInfoAddButtonCell"
        let destructiveButtonCellIdentifier = "ChatInfoDescructiveButtonCell"
        let infoCellIdentifier = "ChatInfoCell"
        
        switch self {
        case .ReportChat, .ExitChat:
            return destructiveButtonCellIdentifier
        case .Shouts, .Media, .Participants, .Blocked:
            return infoCellIdentifier
        case .AddMember:
            return addButtonCellIdentifier
        }
    }
    
    func title() -> String {
        switch self {
        case .Shouts: return NSLocalizedString("Shouts", comment: "Conversation Info Screen Cell Title")
        case .Media: return NSLocalizedString("Media", comment: "Conversation Info Screen Cell Title")
        case .AddMember: return NSLocalizedString("Add Member", comment: "Conversation Info Screen Cell Title")
        case .Participants: return NSLocalizedString("Participants", comment: "Conversation Info Screen Cell Title")
        case .Blocked: return NSLocalizedString("Blocked", comment: "Conversation Info Screen Cell Title")
        case .ReportChat: return NSLocalizedString("Report Chat", comment: "Conversation Info Screen Cell Title")
        case .ExitChat: return NSLocalizedString("Exit Chat", comment: "Conversation Info Screen Cell Title")
        }
    }
    
    func detailTextWithConversation(conversation: Conversation) -> String? {
        switch self {
        case .Shouts: return String(conversation.attachmentCount.shout)
        case .Media: return String(conversation.attachmentCount.media)
        case .Participants: return String(conversation.users?.count ?? 0)
        case .Blocked: return String(conversation.blocked?.count ?? 0)
        default: return nil
        }
    }
}