//
//  EditPageTableViewModel.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 08/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class EditPageTableViewModel {
    
    enum OperationStatus {
        case Ready
        case Error(error: ErrorType)
        case Progress(show: Bool)
    }
    
    let charactersLimit = 150
    
    var user: DetailedPageProfile!
    var cells: [EditPageCellViewModel]
    
    private(set) var avatarUploadTask: MediaUploadingTask?
    private(set) var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .UserImage)
    }()
    
    init(usr: DetailedPageProfile) {
        user = usr
        
        cells = [EditPageCellViewModel(name: user.name ?? ""),
                 EditPageCellViewModel(about: user.about ?? ""),
                 EditPageCellViewModel(phone: user.phone ?? ""),
                 EditPageCellViewModel(founded: user.founded ?? ""),
                 EditPageCellViewModel(description: user.description ?? ""),
                 EditPageCellViewModel(impressum: user.impressum ?? ""),
                 EditPageCellViewModel(overview: user.overview ?? ""),
                 EditPageCellViewModel(mission: user.mission ?? ""),
                 EditPageCellViewModel(general_info: user.general_info ?? "")
//                 EditPageCellViewModel(is_published: user.is_published)
            
            
        ]
    }
    
    // MARK: - Mutation
    
    func mutateModelForIndex(index: Int, object: AnyObject) {
        
        guard let string = object as? String else {
            
            return
        }
        
        let currentModel = cells[index]
        switch currentModel.identity {
        case .Name:
            cells[index] = EditPageCellViewModel(name: string)
        case .About:
            cells[index] = EditPageCellViewModel(about: string)
        case .Description:
            cells[index] = EditPageCellViewModel(description: string)
        case .Phone:
            cells[index] = EditPageCellViewModel(phone: string)
        case .Founded:
            cells[index] = EditPageCellViewModel(founded: string)
        case .Impressum:
            cells[index] = EditPageCellViewModel(impressum: string)
        case .Overview:
            cells[index] = EditPageCellViewModel(overview: string)
        case .Mission:
            cells[index] = EditPageCellViewModel(mission: string)
        case .GeneralInfo:
            cells[index] = EditPageCellViewModel(general_info: string)
        default:
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
        
    }
    
    private func composeParameters() -> EditPageParams {
        
        var name: String?
        var about: String?
        var is_published: Bool?
        var description: String?
        var phone: String?
        var founded: String?
        var impressum: String?
        var overview: String?
        var mission: String?
        var general_info: String?
        var is_verified: Bool?
        
        for cell in cells {
            switch cell {
            case .BasicText(let value, _, .Name):
                name = value
            case .BasicText(let value, _, .About):
                about = value
//            case .IsPublished(let value, _, .IsPublished):
//                is_published = value
            case .BasicText(let value, _, .Description):
                description = value
            case .BasicText(let value, _, .Phone):
                phone = value
            case .BasicText(let value, _, .Founded):
                founded = value
            case .BasicText(let value, _, .Impressum):
                impressum = value
            case .BasicText(let value, _, .Overview):
                overview = value
            case .BasicText(let value, _, .Mission):
                mission = value
            case .BasicText(let value, _, .GeneralInfo):
                general_info = value
//            case .BasicText(let value, _, .IsVerified):
//                is_verified = value
            default:
                break
            }
        }
        
        return EditPageParams(name: name,
                              about: about,
                              description: description,
                              phone: phone,
                              imagePath: avatarUploadTask?.attachment.remoteURL?.absoluteString,
                              coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString,
                              founded: founded,
                              impressum: impressum,
                              overview: overview,
                              mission: mission,
                              general_info: general_info)
    }
}