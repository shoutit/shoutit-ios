//
//  ConversationInfoViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

class ConversationInfoViewModel: ConversationSubjectEditable {
    
    enum OperationStatus {
        case Ready
        case Error(error: ErrorType)
        case Progress(show: Bool)
    }
    
    // data
    var conversation: Conversation {
        didSet {
            self.sectionViewModels = ConversationInfoViewModel.sectionViewModelsWithConversation(conversation)
        }
    }
    private(set) var sectionViewModels: [ConversationInfoSectionViewModel]
    
    // ConversationSubjectEditable
    var chatSubject: String = ""
    private(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .TagImage)
    }()
    
    init(conversation: ShoutitKit.Conversation) {
        self.conversation = conversation
        self.sectionViewModels = ConversationInfoViewModel.sectionViewModelsWithConversation(conversation)
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
        return sectionViewModels.count
    }
    
    func numberOfRows(section: Int) -> Int {
        return sectionViewModels[section].cellViewModels.count
    }
    
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return sectionViewModels[indexPath.section].cellViewModels[indexPath.row].reuseIdentifier()
    }
    
    func sectionTitleForSection(section: Int) -> String {
        return sectionViewModels[section].sectionTitle
    }
    
    func fillCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cellViewModel = sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        cell.tintColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        cell.textLabel?.text = cellViewModel.title()
        cell.detailTextLabel?.text = cellViewModel.detailTextWithConversation(conversation)
    }
}

private extension ConversationInfoViewModel {
    
    static func sectionViewModelsWithConversation(conversation: Conversation) -> [ConversationInfoSectionViewModel] {
        
        let attachmentsSectionViewModel = ConversationInfoSectionViewModel(title: NSLocalizedString("ATTACHMENTS", comment: "Conversation Info Attachments Section Title"),
                                                                           cellViewModels:[.Shouts, .Media])
        var membersCellViewModels: [ConversationInfoCellViewModel] = [.AddMember, .Participants]
        let isAdmin = conversation.isAdmin(Account.sharedInstance.user?.id)
        if isAdmin {
            membersCellViewModels.append(.Blocked)
        }
        let membersSectionViewModel = ConversationInfoSectionViewModel(title: NSLocalizedString("MEMBERS", comment: "Conversation Info Members Section Title"),
                                                                       cellViewModels: membersCellViewModels)
        var destructiveSectionCellViewModels: [ConversationInfoCellViewModel] = []
        if conversation.isPublicChat() {
            destructiveSectionCellViewModels.append(.ReportChat)
        }
        if let currentUserId = Account.sharedInstance.user?.id, users = conversation.users {
            let isMemeber = users.map{$0.value.id}.contains(currentUserId)
            if isMemeber {
                destructiveSectionCellViewModels.append(.ExitChat)
            }
        }
        
        var sections = [attachmentsSectionViewModel, membersSectionViewModel]
        if destructiveSectionCellViewModels.count > 0 {
            sections.append(ConversationInfoSectionViewModel(title: "", cellViewModels: destructiveSectionCellViewModels))
        }
        return sections
    }
    
    func composeParameters() -> ConversationUpdateParams {
        let params = ConversationUpdateParams(subject: chatSubject,
                                              icon: imageUploadTask?.attachment.remoteURL?.absoluteString)
        return params
    }
}

extension ConversationInfoViewModel {
    
    func addParticipantToConversation(profile: Profile) -> Observable<Success> {
        return APIChatsService.addMemberToConversationWithId(self.conversation.id, profile: profile)
    }
    
    func removeParticipantFromConversation(profile: Profile) -> Observable<Success> {
        return APIChatsService.removeMemberFromConversationWithId(self.conversation.id, profile: profile)
    }
}
