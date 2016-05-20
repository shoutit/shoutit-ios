//
//  CreatePublicChatViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class CreatePublicChatViewModel: ConversationSubjectEditable {
    
    enum OperationStatus {
        case Ready
        case Error(error: ErrorType)
        case Progress(show: Bool)
    }
    
    // state
    private(set) var sections: [CreatePublicChatSectionViewModel] = []
    
    // ConversationSubjectEditable
    var chatSubject: String = ""
    private(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .TagImage)
    }()
    
    init() {
        self.sections = createChildViewModels()
    }
    
    // MARK: - Actions
    
    func uploadImageAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        imageUploadTask = task
        return task
    }
    
    func createChat() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            do {
                try self.validateFields()
                observer.onNext(.Progress(show: true))
                return APIPublicChatsService.requestCreatePublicChatWithParams(self.composeParameters()).subscribe{ (event) in
                    observer.onNext(.Progress(show: false))
                    switch event {
                    case .Next:
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
    
    // MARK: - Setup
    
    private func createChildViewModels() -> [CreatePublicChatSectionViewModel] {
        guard let user = Account.sharedInstance.user else { fatalError() }
        let firstSectionCells: [CreatePublicChatCellViewModel] = [.Location(location: user.location)]
        let secondSectionCells: [CreatePublicChatCellViewModel] = [.Selectable(option: .Facebook, selected: true), .Selectable(option: .Twitter, selected: false)]
        let firstSection = CreatePublicChatSectionViewModel(title: NSLocalizedString("LOCATION", comment: "Create public chat section title"),
                                                            cellViewModels: firstSectionCells)
        let secondSection = CreatePublicChatSectionViewModel(title: NSLocalizedString("SHARING", comment: "Create public chat section title"),
                                                            cellViewModels: secondSectionCells)
        return [firstSection, secondSection]
    }
    
    // MARK: - Convenience
    
    private func composeParameters() -> CreatePublicChatParams {
        var address: Address!
        let cellViewModels = sections.flatMap{$0.cellViewModels}
        for cell in cellViewModels {
            switchStatement: switch cell {
            case .Location(let location):
                address = location
            default:
                break switchStatement
            }
        }
        let params = CreatePublicChatParams(subject: chatSubject,
                                            iconPath: imageUploadTask?.attachment.remoteURL?.absoluteString,
                                            location: address)
        return params
    }
}
