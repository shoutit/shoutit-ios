//
//  VerifyPageViewModel.swift
//  shoutit
//
//  Created by Piotr Bernad on 13.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit



final class VerifyPageViewModel {
    typealias ResponseType = PageVerification
    
    private(set) var page: DetailedPageProfile

    var verification: PageVerification?

    var email: Variable<String>
    var contactPerson: Variable<String>
    var contactNumber: Variable<String>
    var businessName: Variable<String>
    var location: Variable<Address?>
    
    init(page: DetailedPageProfile) {
        self.page = page
        self.email = Variable(verification?.businessEmail ?? "")
        self.contactNumber = Variable(verification?.contactNumber ?? "")
        self.businessName = Variable(verification?.businessName ?? "")
        self.contactPerson = Variable(verification?.contactPerson ?? "")
        self.location = Variable(nil)
    }
    
    let successSubject: PublishSubject<ResponseType> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    
    private let disposeBag = DisposeBag()

    private(set) var mediaUploadTasks: [MediaUploadingTask] = []
    lazy var mediaUploader: MediaUploader = {
        //TODO Which bucket should we use?
        return MediaUploader(bucket: .UserImage)
    }()
    
    
    func verifyPageObservable() -> Observable<ResponseType> {
        let username = self.page.username
        let params = self.buildParams()
                
        return APIPageService.verifyPage(params, forPageWithUsername: username)
    }
    
    func verifyPage() {
        progressSubject.onNext(true)
        do {
            try self.contentReady()
        
            verifyPageObservable()
                .subscribe {[weak self] event in
                    self?.progressSubject.onNext(false)
                    switch event {
                    case .Next((let pageVerification)):
                        self?.successSubject.onNext(pageVerification)
                    case .Error(let error):
                        self?.errorSubject.onNext(error)
                    default:
                        break
                    }
                }.addDisposableTo(disposeBag)
        
        } catch (let error) {
            errorSubject.onError(error)
        }
    }
        
       
    
    func uploadAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        mediaUploadTasks.append(task)
        return task
    }
    
    private func contentReady() throws {
        for task in mediaUploadTasks where task.status.value == .Uploading {
            throw LightError(userMessage: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
    }
    
    private func buildParams() -> PageVerificationParams {
        let emailParam = email.value
        let contactPersonParam = contactPerson.value
        let contactNumberParam = contactNumber.value
        let businessNameParam = businessName.value
        
        let imageURLs = mediaUploadTasks.flatMap { $0.attachment.remoteURL?.absoluteString }
        
        return PageVerificationParams(businessName: businessNameParam,
                               contactPerson: contactPersonParam,
                               contactNumber: contactNumberParam,
                               businessEmail: emailParam,
                               location: location.value, images: imageURLs)
    }
}

