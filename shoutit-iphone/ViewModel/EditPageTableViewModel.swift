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
    
    var user: DetailedPageProfile?
    var basicProfile : Profile?
    var cells: [EditPageCellViewModel]
    
    private(set) var avatarUploadTask: MediaUploadingTask?
    private(set) var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .UserImage)
    }()
    
    init(profile: Profile) {
        basicProfile = profile
        
        cells = [EditPageCellViewModel(name: basicProfile?.name ?? ""),
                 EditPageCellViewModel(about:  ""),
                 EditPageCellViewModel(phone:  ""),
                 EditPageCellViewModel(founded:  ""),
                 EditPageCellViewModel(description: ""),
                 EditPageCellViewModel(impressum:  ""),
                 EditPageCellViewModel(overview:  ""),
                 EditPageCellViewModel(mission:  ""),
                 EditPageCellViewModel(general_info: ""),
                 EditPageCellViewModel(published: false)
            
            
        ]
    }
    
    
    
    init(page: DetailedPageProfile) {
        user = page
        
        
        cells = [EditPageCellViewModel(name: page.name ?? ""),
                 EditPageCellViewModel(about: page.about ?? ""),
                 EditPageCellViewModel(phone: page.mobile ?? ""),
                 EditPageCellViewModel(founded: page.founded ?? ""),
                 EditPageCellViewModel(description: page.description ?? ""),
                 EditPageCellViewModel(impressum: page.impressum ?? ""),
                 EditPageCellViewModel(overview: page.overview ?? ""),
                 EditPageCellViewModel(mission: page.mission ?? ""),
                 EditPageCellViewModel(general_info: page.general_info ?? ""),
                 EditPageCellViewModel(published: page.is_published ?? false)
            
            
        ]
    }
    
    func fetchPageProfile() -> Observable<DetailedPageProfile>? {
        guard let page = basicProfile else {return nil}
        return APIProfileService.retrievePageProfileWithUsername(page.username)
    }

    
    // MARK: - Mutation
    
    func mutateModelForIndex(index: Int, object: AnyObject) {
        
        guard let string = object as? String else {
            if let published = object as? Bool {
                cells[index] = EditPageCellViewModel(published: published)
            }
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
        
        guard let user = self.user else {
            return Observable.just(.Ready)
        }
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            do {
                try self.contentReady()
                
                
                
                observer.onNext(.Progress(show: true))
                return  APIProfileService.editPageWithUsername(user.username, withParams: self.composeParameters()).subscribe({ (event) in
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
        
        
        for cell in cells {
            switch cell {
            case .BasicText(let value, _, .Name):
                name = value
            case .RichText(let value, _, .About):
                about = value
            case .Switch(let value, _, .IsPublished):
                is_published = value
            case .RichText(let value, _, .Description):
                description = value
            case .BasicText(let value, _, .Phone):
                phone = value
            case .BasicText(let value, _, .Founded):
                founded = value
            case .RichText(let value, _, .Impressum):
                impressum = value
            case .RichText(let value, _, .Overview):
                overview = value
            case .RichText(let value, _, .Mission):
                mission = value
            case .RichText(let value, _, .GeneralInfo):
                general_info = value
            default:
                break
            }
        }
        
        // TODO: Handle image editing
        return EditPageParams(name: name, imagePath: avatarUploadTask?.attachment.remoteURL?.absoluteString, about: about, description: description, phone: phone, founded: founded, impressum: impressum, overview: overview, mission: mission, general_info: general_info, coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString, is_published: is_published)
      
    }
}