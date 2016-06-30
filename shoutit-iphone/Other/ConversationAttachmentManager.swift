//
//  ConversationAttachmentManager.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

enum PickerAttachmentType {
    case Media
    case Shout
    case Profile
    case Location
}

final class ConversationAttachmentManager {
    
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let pushingSubject: PublishSubject<UIViewController?> = PublishSubject()
    
    let disposeBag = DisposeBag()
    
    var uploader = MediaUploader(bucket: .ShoutImage)
    lazy var mediaPickerController: MediaPickerController = {[unowned self] in
        let settings = MediaPickerSettings(thumbnailSize: CGSize(width: 100, height: 100),
                                           targetSize: PHImageManagerMaximumSize,
                                           contentMode: .AspectFill,
                                           videoLength: 10.0,
                                           maximumItems: 1,
                                           maximumVideos: 1,
                                           allowsVideos: true)
        
        let mediaPicker = MediaPickerController(delegate: self, settings: settings)
        
        mediaPicker.presentingSubject
            .asDriver(onErrorJustReturn: nil)
            .driveNext { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.presentingSubject.onNext(controller)
            }
            .addDisposableTo(self.disposeBag)
        
        return mediaPicker
    }()
    
    private unowned var viewModel: ConversationViewModel
    
    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
    }
    
    func requestAttachmentWithType(type: PickerAttachmentType) {
        switch type {
        case .Media:
            requestMediaAttachment()
        case .Profile:
            requestProfileAttachment()
        case .Location:
            requestLocationAttachment()
        case .Shout:
            requestShoutAttachment()
        }
    }
    
    private func requestLocationAttachment() {
        guard let user = Account.sharedInstance.user else {
            fatalError("User shouldnt be able to create attachment without logging in")
        }
        
        guard let longitude = user.location.longitude, latitude = user.location.latitude else {
            
            let alert = UIAlertController(title: NSLocalizedString("Could not send your location right now.", comment: ""), message: NSLocalizedString("Please make sure that your location services are enabled for Shoutit.", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
            self.presentingSubject.onNext(alert)
            
            return
        }
        
        let locationAttachment = MessageLocation(longitude: longitude, latitude: latitude)
        let attachment = MessageAttachment(shout: nil, location: locationAttachment, profile: nil, videos: nil, images: nil)
        let message = NSLocalizedString("Do you want to send your location?", comment: "")
        showConfirmationControllerWithMessage(message) {[weak self] in
            self?.viewModel.sendMessageWithAttachment(attachment)
        }
    }
    
    private func requestMediaAttachment() {
        mediaPickerController.showMediaPickerController()
    }
    
    private func requestProfileAttachment() {
        let parentController = Wireframe.conversationSelectProfileAttachmentParentController()
        parentController.eventHandler = SelectProfileProfilesListEventHandler {[weak self, weak parentController] (profile) in
            parentController?.navigationController?.popViewControllerAnimated(true)
            let attachment = MessageAttachment(shout: nil, location: nil, profile: profile, videos: nil, images: nil)
            let message = NSLocalizedString("Do you want to send selected profile?", comment: "")
            self?.showConfirmationControllerWithMessage(message) {
                self?.viewModel.sendMessageWithAttachment(attachment)
            }
        }
        self.pushingSubject.onNext(parentController)
    }
    
    private func requestShoutAttachment() {
        let controller = Wireframe.selectShoutAttachmentController()
        controller.shoutPublishSubject.subscribeNext { [weak self] (shout) in
            let attachment = MessageAttachment(shout: shout, location: nil, profile: nil, videos: nil, images: nil)
            let message = NSLocalizedString("Do you want to send selected shout?", comment: "")
            self?.showConfirmationControllerWithMessage(message) {
                self?.viewModel.sendMessageWithAttachment(attachment)
            }
        }.addDisposableTo(disposeBag)
        
        self.pushingSubject.onNext(controller)
    }
    
    private func showConfirmationControllerWithMessage(message: String, completionHandler: (Void -> Void)) {
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: ""), style: .Default, handler: { (_) in
            completionHandler()
        }))
        
        self.presentingSubject.onNext(alert)
    }
}

extension ConversationAttachmentManager: MediaPickerControllerDelegate {
    
    func attachmentsSelected(attachments: [MediaAttachment], mediaPicker: MediaPickerController) {
        guard let type = attachments.first?.type else { return }
        let message: String
        switch (type, attachments.count > 1) {
        case (.Video, true): message = NSLocalizedString("Do you want to send selected videos?", comment: "")
        case (.Video, false): message = NSLocalizedString("Do you want to send selected video?", comment: "")
        case (.Image, true): message = NSLocalizedString("Do you want to send selected pictures?", comment: "")
        case (.Image, false): message = NSLocalizedString("Do you want to send selected picture?", comment: "")
        default: return
        }
        
        showConfirmationControllerWithMessage(message) { [weak self] in
            self?.uploadMediaAttachments(attachments)
        }
    }
    
    func uploadMediaAttachments(attachments: [MediaAttachment]) {
        
        let queue = dispatch_queue_create("com.shoutit.conversation.photos", DISPATCH_QUEUE_CONCURRENT)
        let group = dispatch_group_create()
        
        var tasks = [MediaUploadingTask]()
        
        dispatch_apply(attachments.count, queue) { (iteration) in
            
            dispatch_group_enter(group)
            let task = self.uploader.uploadAttachment(attachments[iteration])
            tasks.append(task)
            
            task.status.asObservable().subscribeNext { (status) in
                if status == .Uploaded {
                    dispatch_group_leave(group)
                }
            }.addDisposableTo(self.disposeBag)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            for task in tasks {
                let attachment = task.attachment.asMessageAttachment()
                self.viewModel.sendMessageWithAttachment(attachment)
            }
        }
    }
}