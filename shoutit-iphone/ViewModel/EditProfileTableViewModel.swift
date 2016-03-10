//
//  EditProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class EditProfileTableViewModel {
    
    enum OperationStatus {
        case Ready
        case Error(error: ErrorType)
        case Progress(show: Bool)
    }
    
    let updateReadySubject: PublishSubject<Void> = PublishSubject()
    let messageSubject: PublishSubject<String> = PublishSubject()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    
    let user: LoggedUser
    var cells: [EditProfileCellViewModel]
    
    var avatarUploadTask: MediaUploadingTask?
    var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .UserImage)
    }()
    
    init() {
        precondition(Account.sharedInstance.loggedUser != nil)
        user = Account.sharedInstance.loggedUser!
        cells = [EditProfileCellViewModel(name: user.name),
                 EditProfileCellViewModel(username: user.username),
                 EditProfileCellViewModel(bio: user.bio),
                 EditProfileCellViewModel(location: user.location),
                 EditProfileCellViewModel(website: user.website ?? "")]
    }
    
    // MARK: - Mutation
    
    func mutateModelForIndex(index: Int, withString string: String) {
        switch index {
        case 0:
            cells[index] = EditProfileCellViewModel(name: string)
        case 1:
            cells[index] = EditProfileCellViewModel(username: string)
        case 2:
            cells[index] = EditProfileCellViewModel(bio: string)
        case 4:
            cells[index] = EditProfileCellViewModel(website: string)
        default:
            assertionFailure()
        }
    }
    
    // MARK: Actions
    
    func save() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            do {
                try self.contentReady()
                
                observer.onNext(.Progress(show: true))
                return  APIProfileService.editUserWithUsername(self.user.username, withParams: self.composeParameters()).subscribe({ (event) in
                    observer.onNext(.Progress(show: false))
                    switch event {
                    case .Next(let loggedUser):
                        Account.sharedInstance.loggedUser = loggedUser
                        observer.onNext(.Ready)
                    case .Error(let error):
                        observer.onNext(.Error(error: error))
                        observer.onCompleted()
                    case .Completed:
                        observer.onCompleted()
                    }
                })
            }
            catch (let error) {
                observer.onNext(.Error(error: error))
                observer.onCompleted()
            }

            return NopDisposable.instance
        }
        
    }
    
    func uploadCoverAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        coverUploadTask = task
        return task
    }
    
    func uploadAvatarAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        avatarUploadTask = task
        return task
    }
    
    // MARK: - Convenience
    
    private func contentReady() throws {
        if let task = avatarUploadTask where task.status.value == .Uploading {
            throw LightError(message: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
        if let task = coverUploadTask where task.status.value == .Uploading {
            throw LightError(message: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
        
        let bioCellViewModel = cells[2]
        if case .RichText(let bio, _) = bioCellViewModel {
            if bio.characters.count > 250 {
                throw LightError(message: NSLocalizedString("Bio has too many characters", comment: ""))
            }
        }
    }
    
    private func composeParameters() -> EditProfileParams {
        
        var name: String?
        var username: String?
        var bio: String?
        var website: String?
        var location: Address?
        
        for (index, cellModel) in cells.enumerate() {
            switch index {
            case 0:
                if case .BasicText(let value, _) = cellModel {
                    name = value
                }
            case 1:
                if case .BasicText(let value, _) = cellModel {
                    username = value
                }
            case 2:
                if case .RichText(let value, _) = cellModel {
                    bio = value
                }
            case 3:
                if case .Location(let value, _) = cellModel {
                    location = value
                }
            case 4:
                if case .BasicText(let value, _) = cellModel {
                    website = value
                }
            default:
                break
            }
        }
        
        return EditProfileParams(name: name, username: username, bio: bio, website: website, location: location, imagePath: avatarUploadTask?.attachment.remoteURL?.absoluteString, coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString)
    }
}
