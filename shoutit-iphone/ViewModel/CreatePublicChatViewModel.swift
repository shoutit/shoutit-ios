//
//  CreatePublicChatViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

class CreatePublicChatViewModel: ConversationSubjectEditable {
    
    enum OperationStatus {
        case ready
        case error(error: Error)
        case progress(show: Bool)
    }
    
    // state
    fileprivate(set) var sections: [CreatePublicChatSectionViewModel] = []
    
    // ConversationSubjectEditable
    var chatSubject: String = ""
    fileprivate(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .tagImage)
    }()
    
    init() {
        self.sections = createChildViewModels()
    }
    
    // MARK: - Actions
    
    func uploadImageAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        imageUploadTask = task
        return task
    }
    
    func createChat() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            do {
                try self.validateFields()
                observer.onNext(.progress(show: true))
                return APIPublicChatsService.requestCreatePublicChatWithParams(self.composeParameters()).subscribe{ (event) in
                    observer.onNext(.progress(show: false))
                    switch event {
                    case .next:
                        observer.onNext(.ready)
                    case .Error(let error):
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
    
    // MARK: - Setup
    
    fileprivate func createChildViewModels() -> [CreatePublicChatSectionViewModel] {
        guard let user = Account.sharedInstance.user else { fatalError() }
        let firstSectionCells: [CreatePublicChatCellViewModel] = [.location(location: user.location)]
//        let secondSectionCells: [CreatePublicChatCellViewModel] = [.Selectable(option: .Facebook, selected: true), .Selectable(option: .Twitter, selected: false)]
        let firstSection = CreatePublicChatSectionViewModel(title: NSLocalizedString("LOCATION", comment: "Create public chat section title"),
                                                            cellViewModels: firstSectionCells)
        // No Sharing in this version
        /*        let secondSection = CreatePublicChatSectionViewModel(title: NSLocalizedString("SHARING", comment: "Create public chat section title"), cellViewModels: secondSectionCells) */
        return [firstSection /*, secondSection */]
    }
    
    // MARK: - Convenience
    
    fileprivate func composeParameters() -> CreatePublicChatParams {
        var address: Address!
        let cellViewModels = sections.flatMap{$0.cellViewModels}
        for cell in cellViewModels {
            switchStatement: switch cell {
            case .location(let location):
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
