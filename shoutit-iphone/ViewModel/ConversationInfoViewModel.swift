//
//  ConversationInfoViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ConversationInfoViewModel: ConversationSubjectEditable {
    
    enum OperationStatus {
        case Ready
        case Error(error: ErrorType)
        case Progress(show: Bool)
    }
    
    private let addButtonCellIdentifier = "ChatInfoAddButtonCell"
    private let destructiveButtonCellIdentifier = "ChatInfoDescructiveButtonCell"
    private let infoCellIdentifier = "ChatInfoCell"
    
    // data
    var conversation: Conversation
    
    // ConversationSubjectEditable
    var chatSubject: String = ""
    private(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .TagImage)
    }()
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    // MARK: - Actions
    
    func uploadImageAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        imageUploadTask = task
        return task
    }
    
    func saveChat() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            do {
                try self.validateFields()
                observer.onNext(.Progress(show: true))
                
                return APIChatsService
                    .updateConversationWithId(self.conversation.id, params: self.composeParameters())
                    .subscribe { [weak self] (event) in
                        observer.onNext(.Progress(show: false))
                        switch event {
                        case .Next(let conversation):
                            self?.conversation = conversation
                            observer.onNext(.Ready)
                        case .Error(let error):
                            observer.onNext(.Error(error: error))
                            observer.onCompleted()
                        case .Completed:
                            observer.onCompleted()
                        }
                    }
            }
            catch (let error) {
                observer.onNext(.Error(error: error))
                observer.onCompleted()
            }
            return NopDisposable.instance
        }
    }
    
    // MARK: - Table view data
    
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
        
        cell.tintColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Shouts", comment: "")
                cell.detailTextLabel?.text = String(conversation.attachmentCount.shout)
                
            case 1:
                cell.textLabel?.text = NSLocalizedString("Media", comment: "")
                cell.detailTextLabel?.text = String(conversation.attachmentCount.media)
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
                cell.textLabel?.text = NSLocalizedString("Report Chat", comment: "")
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

private extension ConversationInfoViewModel {
    
    func composeParameters() -> ConversationUpdateParams {
        let params = ConversationUpdateParams(subject: chatSubject,
                                              icon: imageUploadTask?.attachment.remoteURL?.absoluteString)
        return params
    }
}

extension ConversationInfoViewModel {
    
    func addParticipantToConversation(profile: Profile) -> Observable<Void> {
        return APIChatsService.addMemberToConversationWithId(self.conversation.id, profile: profile)
    }
}
