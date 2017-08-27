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
        case ready
        case error(error: Error)
        case progress(show: Bool)
    }
    
    // data
    var conversation: Conversation {
        didSet {
            self.sectionViewModels = ConversationInfoViewModel.sectionViewModelsWithConversation(conversation)
        }
    }
    fileprivate(set) var sectionViewModels: [ConversationInfoSectionViewModel]
    
    // ConversationSubjectEditable
    var chatSubject: String = ""
    fileprivate(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .tagImage)
    }()
    
    init(conversation: ShoutitKit.Conversation) {
        self.conversation = conversation
        self.sectionViewModels = ConversationInfoViewModel.sectionViewModelsWithConversation(conversation)
    }
    
    // MARK: - Actions
    
    func uploadImageAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        imageUploadTask = task
        return task
    }
    
    func saveChat() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            do {
                try self.validateFields()
                observer.onNext(.progress(show: true))
                
                return APIChatsService
                    .updateConversationWithId(self.conversation.id, params: self.composeParameters())
                    .subscribe { [weak self] (event) in
                        observer.onNext(.progress(show: false))
                        switch event {
                        case .next(let conversation):
                            self?.conversation = conversation
                            observer.onNext(.ready)
                        case .error(let error):
                            observer.onNext(.error(error: error))
                            observer.onCompleted()
                        case .completed:
                            observer.onCompleted()
                        }
                    }
            }
            catch (let error) {
                observer.onNext(.error(error: error))
                observer.onCompleted()
            }
            return NopDisposable.instance
        }
    }
    
    // MARK: - Table view data
    
    func numberOfSections() -> Int {
        return sectionViewModels.count
    }
    
    func numberOfRows(_ section: Int) -> Int {
        return sectionViewModels[section].cellViewModels.count
    }
    
    func cellIdentifierForIndexPath(_ indexPath: IndexPath) -> String {
        return sectionViewModels[indexPath.section].cellViewModels[indexPath.row].reuseIdentifier()
    }
    
    func sectionTitleForSection(_ section: Int) -> String {
        return sectionViewModels[section].sectionTitle
    }
    
    func fillCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let cellViewModel = sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        cell.tintColor = UIColor(shoutitColor: .shoutitLightBlueColor)
        cell.textLabel?.text = cellViewModel.title()
        cell.detailTextLabel?.text = cellViewModel.detailTextWithConversation(conversation)
    }
}

private extension ConversationInfoViewModel {
    
    static func sectionViewModelsWithConversation(_ conversation: Conversation) -> [ConversationInfoSectionViewModel] {
        
        let attachmentsSectionViewModel = ConversationInfoSectionViewModel(title: NSLocalizedString("ATTACHMENTS", comment: "Conversation Info Attachments Section Title"),
                                                                           cellViewModels:[.shouts, .media])
        var membersCellViewModels: [ConversationInfoCellViewModel] = [.addMember, .participants]
        let isAdmin = conversation.isAdmin(Account.sharedInstance.user?.id)
        if isAdmin {
            membersCellViewModels.append(.blocked)
        }
        let membersSectionViewModel = ConversationInfoSectionViewModel(title: NSLocalizedString("MEMBERS", comment: "Conversation Info Members Section Title"),
                                                                       cellViewModels: membersCellViewModels)
        var destructiveSectionCellViewModels: [ConversationInfoCellViewModel] = []
        if conversation.isPublicChat() {
            destructiveSectionCellViewModels.append(.reportChat)
        }
        if let currentUserId = Account.sharedInstance.user?.id, let users = conversation.users {
            let isMemeber = users.map{$0.value.id}.contains(currentUserId)
            if isMemeber {
                destructiveSectionCellViewModels.append(.exitChat)
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
    
    func addParticipantToConversation(_ profile: Profile) -> Observable<Success> {
        return APIChatsService.addMemberToConversationWithId(self.conversation.id, profile: profile)
    }
    
    func removeParticipantFromConversation(_ profile: Profile) -> Observable<Success> {
        return APIChatsService.removeMemberFromConversationWithId(self.conversation.id, profile: profile)
    }
}
