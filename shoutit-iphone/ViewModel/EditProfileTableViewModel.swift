//
//  EditProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class EditProfileTableViewModel {
    
    enum OperationStatus {
        case ready
        case error(error: Error)
        case progress(show: Bool)
    }
    
    let charactersLimit = 150
    
    let user: DetailedUserProfile
    var cells: [EditProfileCellViewModel]
    
    fileprivate(set) var avatarUploadTask: MediaUploadingTask?
    fileprivate(set) var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .userImage)
    }()
    
    init() {
        switch Account.sharedInstance.loginState {
        case .logged(let logged)?:
            self.user = logged
        case .page(_, _)?:
            fatalError()
        default:
            fatalError()
        }
        cells = [EditProfileCellViewModel(firstname: user.firstName ?? ""),
                 EditProfileCellViewModel(lastname: user.lastName ?? ""),
                 EditProfileCellViewModel(username: user.username),
                 EditProfileCellViewModel(bio: user.bio ?? ""),
                 EditProfileCellViewModel(location: user.location),
                 EditProfileCellViewModel(website: user.website ?? ""),
                 EditProfileCellViewModel(mobile: user.mobile ?? ""),
                 EditProfileCellViewModel(birthday: DateFormatters.sharedInstance.dateFromApiString(user.birthday)),
                 EditProfileCellViewModel(gender: ((user.gender != nil) ? (user.gender!.rawValue) : NSLocalizedString("Not specified", comment: "Edit Profile Not Specified Gender")))
            
        ]
    }
    
    // MARK: - Mutation
    
    func mutateModelForIndex(_ index: Int, object: AnyObject) {
        
        guard let string = object as? String else {
            
            if let date = object as? Date {
                mutateBirthdayWithDate(date)
            }
            
            return
        }
        
        let currentModel = cells[index]
        switch currentModel.identity {
        case .firstname:
            cells[index] = EditProfileCellViewModel(firstname: string)
        case .lastname:
            cells[index] = EditProfileCellViewModel(lastname: string)
        case .name:
            cells[index] = EditProfileCellViewModel(name: string)
        case .username:
            cells[index] = EditProfileCellViewModel(username: string)
        case .bio:
            cells[index] = EditProfileCellViewModel(bio: string)
        case .website:
            cells[index] = EditProfileCellViewModel(website: string)
        case .mobile:
            cells[index] = EditProfileCellViewModel(mobile: string)
        case .gender:
            cells[index] = EditProfileCellViewModel(gender: string)
        default:
            break
        }
    }
    
    func mutateBirthdayWithDate(_ date: Date?) {
        cells[9] = EditProfileCellViewModel(birthday: date as! NSDate)
    }
    
    // MARK: Actions
    
    func save() -> Observable<OperationStatus> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            do {
                try self.contentReady()
                
                observer.onNext(.progress(show: true))
                return  APIProfileService.editUserWithUsername(self.user.username, withParams: self.composeParameters()).subscribe({ (event) in
                    observer.onNext(.progress(show: false))
                    switch event {
                    case .next(let loggedUser):
                        Account.sharedInstance.updateUserWithModel(loggedUser)
                        observer.onNext(.ready)
                    case .Error(let error):
                        observer.onNext(.error(error: error))
                        observer.onCompleted()
                    case .completed:
                        observer.onCompleted()
                    }
                })
            }
            catch (let error) {
                observer.onNext(.error(error: error))
                observer.onCompleted()
            }
            return NopDisposable.instance
        }
    }
    
    func uploadCoverAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        coverUploadTask = task
        return task
    }
    
    func uploadAvatarAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        avatarUploadTask = task
        return task
    }
    
    // MARK: - Convenience
    
    fileprivate func contentReady() throws {
        if let task = avatarUploadTask, task.status.value == .uploading {
            throw LightError(userMessage: LocalizedString.Media.waitUntilUpload)
        }
        if let task = coverUploadTask, task.status.value == .uploading {
            throw LightError(userMessage: LocalizedString.Media.waitUntilUpload)
        }
        
        for case .richText(let bio, _, .bio) in cells where bio.characters.count > charactersLimit {
            throw LightError(userMessage: LocalizedString.Media.waitUntilUpload)
        }
    }
    
    fileprivate func composeParameters() -> EditProfileParams {
        
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
            case .basicText(let value, _, .firstname):
                firstname = value
            case .basicText(let value, _, .lastname):
                lastname = value
            case .basicText(let value, _, .name):
                name = value
            case .basicText(let value, _, .username):
                username = value
            case .richText(let value, _, .bio):
                bio = value
            case .location(let value, _, .location):
                location = value
            case .basicText(let value, _, .website):
                website = value
            case .basicText(let value, _, .mobile):
                mobile = value
            case .date(let value, _, .birthday):
                if let value = value {
                    birthday = DateFormatters.sharedInstance.apiStringFromDate(value)
                }
            case .gender(let value, _, .gender):
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
