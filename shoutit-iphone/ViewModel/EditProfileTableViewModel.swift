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
    
    let charactersLimit = 150
    
    let user: DetailedProfile
    var cells: [EditProfileCellViewModel]
    
    private(set) var avatarUploadTask: MediaUploadingTask?
    private(set) var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .UserImage)
    }()
    
    init() {
        guard case .Logged(let user)? = Account.sharedInstance.userModel else { preconditionFailure() }
        self.user = user
        cells = [EditProfileCellViewModel(firstname: user.firstName ?? ""),
                 EditProfileCellViewModel(lastname: user.lastName ?? ""),
                 EditProfileCellViewModel(username: user.username),
                 EditProfileCellViewModel(bio: user.bio ?? ""),
                 EditProfileCellViewModel(location: user.location),
                 EditProfileCellViewModel(website: user.website ?? ""),
                 EditProfileCellViewModel(mobile: user.mobile ?? ""),
                 EditProfileCellViewModel(birthday: user.birthday),
                 EditProfileCellViewModel(gender: ((user.gender != nil) ? (user.gender!.rawValue) : NSLocalizedString("Not specified", comment: "")))
            
        ]
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
        case .Mobile:
            cells[index] = EditProfileCellViewModel(mobile: string)
        case .Birthday:
            cells[index] = EditProfileCellViewModel(birthday: string)
        case .Gender:
            cells[index] = EditProfileCellViewModel(gender: string)
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
                        Account.sharedInstance.updateUserWithModel(loggedUser)
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
        
        for case .RichText(let bio, _, .Bio) in cells where bio.characters.count > charactersLimit {
            throw LightError(userMessage: NSLocalizedString("Bio has too many characters", comment: ""))
        }
    }
    
    private func composeParameters() -> EditProfileParams {
        
        var firstname: String?
        var lastname: String?
        var name: String?
        var username: String?
        var bio: String?
        var website: String?
        var mobile: String?
        var location: Address?
        var birthday: String?
        var gender: Gender?
        
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
            case .BasicText(let value, _, .Mobile):
                mobile = value
            case .Date(let value, _, .Birthday):
                birthday = value
            case .Gender(let value, _, .Gender):
                if value != nil {
                    gender = Gender(rawValue: value!)
                }
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
                                 coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString,
                                 mobile: mobile,
                                 birthday: birthday,
                                 gender: gender)
    }
}
