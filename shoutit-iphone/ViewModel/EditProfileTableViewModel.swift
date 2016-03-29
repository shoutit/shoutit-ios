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
        cells = [EditProfileCellViewModel(firstname: user.firstName),
                 EditProfileCellViewModel(lastname: user.lastName),
                 EditProfileCellViewModel(username: user.username),
                 EditProfileCellViewModel(bio: user.bio ?? ""),
                 EditProfileCellViewModel(location: user.location),
                 EditProfileCellViewModel(website: user.website ?? "")]
    }
    
    // MARK: - Mutation
    
    func mutateModelForIndex(index: Int, withString string: String) {
        let currentModel = cells[index]
        switch currentModel.identity {
        case .Firstname:
            cells[index] = EditProfileCellViewModel(firstname: string)
        case .Lastname:
            cells[index] = EditProfileCellViewModel(lastname: string)
        case .Name:
            cells[index] = EditProfileCellViewModel(name: string)
        case .Username:
            cells[index] = EditProfileCellViewModel(username: string)
        case .Bio:
            cells[index] = EditProfileCellViewModel(bio: string)
        case .Website:
            cells[index] = EditProfileCellViewModel(website: string)
        case .Location:
            break
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
            throw LightError(userMessage: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
        if let task = coverUploadTask where task.status.value == .Uploading {
            throw LightError(userMessage: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
        
        for cell in cells {
            if case .RichText(let bio, _, .Bio) = cell {
                if bio.characters.count > 50 {
                    throw LightError(userMessage: NSLocalizedString("Bio has too many characters", comment: ""))
                }
            }
        }
    }
    
    private func composeParameters() -> EditProfileParams {
        
        var firstname: String?
        var lastname: String?
        var name: String?
        var username: String?
        var bio: String?
        var website: String?
        var location: Address?
        
        for cell in cells {
            switch cell {
            case .BasicText(let value, _, .Firstname):
                firstname = value
            case .BasicText(let value, _, .Lastname):
                lastname = value
            case .BasicText(let value, _, .Name):
                name = value
            case .BasicText(let value, _, .Username):
                username = value
            case .RichText(let value, _, .Bio):
                bio = value
            case .Location(let value, _, .Location):
                location = value
            case .BasicText(let value, _, .Website):
                website = value
            default:
                break
            }
        }
        
        return EditProfileParams(firstname: firstname,
                                 lastname: lastname,
                                 name: name,
                                 username: username,
                                 bio: bio,
                                 website: website,
                                 location: location,
                                 imagePath: avatarUploadTask?.attachment.remoteURL?.absoluteString,
                                 coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString)
    }
}
