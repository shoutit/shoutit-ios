//
//  ConversationInfoViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationInfoViewModel: AnyObject {
    
    private let addButtonCellIdentifier = "ChatInfoAddButtonCell"
    private let destructiveButtonCellIdentifier = "ChatInfoDescructiveButtonCell"
    private let infoCellIdentifier = "ChatInfoCell"
    
    var conversation: Conversation!
    
    func numberOfSections() -> Int {
        return 3
    }
    
    func numberOfRows(section: Int) -> Int {
        switch section {
            case 0:
                return 2
            case 1:
                return 3
            case 2:
                return 2
            default:
                return 0
            
        }
    }
    
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        switch indexPath.section {
        case 0:
            return infoCellIdentifier
        
        case 1:
            switch indexPath.row {
                case 0:
                    return addButtonCellIdentifier
                default:
                    return infoCellIdentifier
            }
        default:
             return destructiveButtonCellIdentifier
        }
    }
    
    func sectionTitleForSection(section: Int) -> String {
        switch section {
        case 0:
            return NSLocalizedString("ATTACHMENTS", comment: "")
            
        case 1:
            return NSLocalizedString("MEMBERS", comment: "")
        default:
            return ""
        }
    }
    
    
    func fillCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Shouts", comment: "")
                cell.detailTextLabel?.text = NSLocalizedString("Shouts", comment: "")
                
            case 1:
                cell.textLabel?.text = NSLocalizedString("Media", comment: "")
                cell.detailTextLabel?.text = NSLocalizedString("Media", comment: "")
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Add Member", comment: "")
                
            case 1:
                cell.textLabel?.text = NSLocalizedString("Participants", comment: "")
                cell.detailTextLabel?.text = NSLocalizedString("\(self.conversation.users?.count ?? 0)", comment: "Participants count")
            case 2:
                cell.textLabel?.text = NSLocalizedString("Blocked", comment: "")
                cell.detailTextLabel?.text = NSLocalizedString("\(self.conversation.blocked.count)", comment: "Blocked Users count")
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Clear Cache", comment: "")
                
            case 1:
                cell.textLabel?.text = NSLocalizedString("Exit Chat", comment: "")
            default:
                break
            }
        default:
            break
        
        }
    }
    
}
