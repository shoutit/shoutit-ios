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
    case media
    case shout
    case profile
    case location
}

final class ConversationAttachmentManager: MediaPickerControllerDelegate {
    let attachmentSelected : PublishSubject<MessageAttachment> = PublishSubject()
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let pushingSubject: PublishSubject<UIViewController?> = PublishSubject()
    
    let disposeBag = DisposeBag()
    
    var tasks : [MediaUploadingTask: Disposable] = [:]
    var uploader = MediaUploader(bucket: .shoutImage)
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
            .drive(onNext: { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.presentingSubject.onNext(controller)
            })
            .addDisposableTo(self.disposeBag)
        
        return mediaPicker
    }()
    
    func requestAttachmentWithType(_ type: PickerAttachmentType) {
        switch type {
        case .media:
            requestMediaAttachment()
        case .profile:
            requestProfileAttachment()
        case .location:
            requestLocationAttachment()
        case .shout:
            requestShoutAttachment()
        }
    }
    
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        let task = uploader.uploadAttachment(attachment)
        
        let subscription = task.status.asDriver().drive(onNext: { [weak self] (status) in
            if status == .uploaded {
                self?.taskCompleted(task)
            }
        })
        
        tasks[task] = subscription
    }
    
    func taskCompleted(_ task: MediaUploadingTask) {
        let subscription = tasks[task]
        
        subscription?.dispose()
        
        let attachment = task.attachment.asMessageAttachment()
        
        showConfirmationControllerForAttachment(attachment)
    }
    
    fileprivate func requestLocationAttachment() {
        guard let user = Account.sharedInstance.user else {
            fatalError("User shouldnt be able to create attachment without logging in")
        }
        
        guard let longitude = user.location.longitude, let latitude = user.location.latitude else {
            
            let alert = UIAlertController(title: NSLocalizedString("Could not send your location right now.", comment: "Sending Location Error"), message: NSLocalizedString("Please make sure that your location services are enabled for Shoutit.", comment: "No location services message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .cancel, handler: nil))
            self.presentingSubject.onNext(alert)
            
            return
        }
        
        let locationAttachment = MessageLocation(longitude: longitude, latitude: latitude)
        let attachment = MessageAttachment(shout: nil, location: locationAttachment, profile: nil, videos: nil, images: nil)
        
        showConfirmationControllerForAttachment(attachment)
    }
    
    fileprivate func requestMediaAttachment() {
        mediaPickerController.showMediaPickerController()
    }
    
    fileprivate func requestProfileAttachment() {
        let parentController = Wireframe.conversationSelectProfileAttachmentParentController()
        parentController.eventHandler = SelectProfileProfilesListEventHandler {[weak self, weak parentController] (profile) in
            parentController?.navigationController?.popViewController(animated: true)
            let attachment = MessageAttachment(shout: nil, location: nil, profile: profile, videos: nil, images: nil)
            self?.showConfirmationControllerForAttachment(attachment)
        }
        self.pushingSubject.onNext(parentController)
    }
    
    fileprivate func requestShoutAttachment() {

        let controller = Wireframe.selectShoutAttachmentController()
        
        controller.shoutPublishSubject.subscribe(onNext: { [weak self] (shout) in
            let attachment = MessageAttachment(shout: shout, location: nil, profile: nil, videos: nil, images: nil)
            self?.showConfirmationControllerForAttachment(attachment)
        }).addDisposableTo(disposeBag)
        
        self.pushingSubject.onNext(controller)
    }
    
    fileprivate func showConfirmationControllerForAttachment(_ attachment: MessageAttachment) {
        guard let attachmentType = attachment.type() else { return }
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: "Send attachment action sheet title"), message: confirmationMessageForType(attachmentType), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: "Send attachment action sheet option"), style: .default, handler: { (alertAction) in
            self.attachmentSelected.onNext(attachment)
        }))
        
        self.presentingSubject.onNext(alert)
    }
    
    fileprivate func confirmationMessageForType(_ type: MessageAttachmentType) -> String {
        switch type {
        case .videoAttachment:
            return NSLocalizedString("Do you want to send selected video?", comment: "Send Attachment question")
        case .shoutAttachment:
            return NSLocalizedString("Do you want to send selected shout?", comment: "Send Attachment question")
        case .locationAttachment:
            return NSLocalizedString("Do you want to send your location?", comment: "Send Attachment question")
        case .imageAttachment:
            return NSLocalizedString("Do you want to send selected picture?", comment: "Send Attachment question")
        case .profileAttachment:
            return NSLocalizedString("Do you want to send selected profile?", comment: "Send Attachment question")
        }
    }
    
}
