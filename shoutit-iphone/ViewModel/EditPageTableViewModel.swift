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
        case ready
        case error(error: Error)
        case progress(show: Bool)
    }
    
    let charactersLimit = 150
    
    var user: DetailedPageProfile?
    var basicProfile : Profile?
    var cells: [EditPageCellViewModel]
    
    fileprivate(set) var avatarUploadTask: MediaUploadingTask?
    fileprivate(set) var coverUploadTask: MediaUploadingTask?
    
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .userImage)
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
                 EditPageCellViewModel(published: page.isPublished ?? false)
            
            
        ]
    }
    
    func fetchPageProfile() -> Observable<DetailedPageProfile>? {
        guard let page = basicProfile else {return nil}
        return APIProfileService.retrievePageProfileWithUsername(page.username)
    }

    
    // MARK: - Mutation
    
    func mutateModelForIndex(_ index: Int, object: AnyObject) {
        
        guard let string = object as? String else {
            if let published = object as? Bool {
                cells[index] = EditPageCellViewModel(published: published)
            }
            return
        }
        
        let currentModel = cells[index]
        switch currentModel.identity {
        case .name:
            cells[index] = EditPageCellViewModel(name: string)
        case .about:
            cells[index] = EditPageCellViewModel(about: string)
        case .description:
            cells[index] = EditPageCellViewModel(description: string)
        case .phone:
            cells[index] = EditPageCellViewModel(phone: string)
        case .founded:
            cells[index] = EditPageCellViewModel(founded: string)
        case .impressum:
            cells[index] = EditPageCellViewModel(impressum: string)
        case .overview:
            cells[index] = EditPageCellViewModel(overview: string)
        case .mission:
            cells[index] = EditPageCellViewModel(mission: string)
        case .generalInfo:
            cells[index] = EditPageCellViewModel(general_info: string)
        default:
            break
        }
    }
    
    // MARK: Actions
    
    func save() -> Observable<OperationStatus> {
        
        guard let user = self.user else {
            return Observable.just(.ready)
        }
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            do {
                try self.contentReady()
                
                
                
                observer.onNext(.progress(show: true))
                return  APIProfileService.editPageWithUsername(user.username, withParams: self.composeParameters()).subscribe({ (event) in
                    observer.onNext(.progress(show: false))
                    switch event {
                    case .next(let loggedUser):
                        Account.sharedInstance.updateUserWithModel(loggedUser)
                        observer.onNext(.ready)
                    case .error(let error):
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
            return Disposables.create {}
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
        
    }
    
    fileprivate func composeParameters() -> EditPageParams {
        
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
            case .basicText(let value, _, .name):
                name = value
            case .richText(let value, _, .about):
                about = value
            case .switch(let value, _, .isPublished):
                is_published = value
            case .richText(let value, _, .description):
                description = value
            case .basicText(let value, _, .phone):
                phone = value
            case .basicText(let value, _, .founded):
                founded = value
            case .richText(let value, _, .impressum):
                impressum = value
            case .richText(let value, _, .overview):
                overview = value
            case .richText(let value, _, .mission):
                mission = value
            case .richText(let value, _, .generalInfo):
                general_info = value
            default:
                break
            }
        }
        
        // TODO: Handle image editing
        return EditPageParams(name: name, imagePath: avatarUploadTask?.attachment.remoteURL?.absoluteString, about: about, description: description, phone: phone, founded: founded, impressum: impressum, overview: overview, mission: mission, general_info: general_info, coverPath: coverUploadTask?.attachment.remoteURL?.absoluteString, is_published: is_published)
      
    }
}
