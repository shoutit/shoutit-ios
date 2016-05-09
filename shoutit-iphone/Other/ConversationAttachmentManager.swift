//
//  ConversationAttachmentManager.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import Nemo

enum PickerAttachmentType {
    case Media
    case Shout
    case Profile
    case Location
}

final class ConversationAttachmentManager: MediaPickerControllerDelegate {
    let attachmentSelected : PublishSubject<MessageAttachment> = PublishSubject()
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    
    let disposeBag = DisposeBag()
    
    var tasks : [MediaUploadingTask: Disposable] = [:]
    
    var uploader = MediaUploader(bucket: .ShoutImage)
    
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
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        let task = uploader.uploadAttachment(attachment)
        
        let subscription = task.status.asDriver().driveNext { [weak self] (status) in
            if status == .Uploaded {
                self?.taskCompleted(task)
            }
        }
        
        tasks[task] = subscription
    }
    
    func taskCompleted(task: MediaUploadingTask) {
        let subscription = tasks[task]
        
        subscription?.dispose()
        
        let attachment = task.attachment.asMessageAttachment()
        
        showConfirmationControllerForAttachment(attachment)
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
        
        showConfirmationControllerForAttachment(attachment)
    }
    
    private func requestMediaAttachment() {
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
            .addDisposableTo(disposeBag)
        
        mediaPicker.showMediaPickerController()
    }
    
    private func requestProfileAttachment() {
        
    }
    
    private func requestShoutAttachment() {

        let controller = Wireframe.selectShoutAttachmentController()
        
        controller.shoutPublishSubject.subscribeNext { [weak self] (shout) in
            let attachment = MessageAttachment(shout: shout, location: nil, profile: nil, videos: nil, images: nil)
            self?.showConfirmationControllerForAttachment(attachment)
        }.addDisposableTo(disposeBag)
        
        self.presentingSubject.onNext(controller)
        
    }
    
    private func showConfirmationControllerForAttachment(attachment: MessageAttachment) {
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: confirmationMessageForType(attachment.type()), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: ""), style: .Default, handler: { (alertAction) in
            self.attachmentSelected.onNext(attachment)
        }))
        
        self.presentingSubject.onNext(alert)
    }
    
    private func confirmationMessageForType(type: MessageAttachmentType) -> String {
        switch type {
        case .VideoAttachment:
            return NSLocalizedString("Do you want to send selected video?", comment: "")
        case .ShoutAttachment:
            return NSLocalizedString("Do you want to send selected shout?", comment: "")
        case .LocationAttachment:
            return NSLocalizedString("Do you want to send your location?", comment: "")
        case .ImageAttachment:
            return NSLocalizedString("Do you want to send selected picture?", comment: "")
        case .ProfileAttachment:
            return NSLocalizedString("Do you want to send selected profile?", comment: "")
        }
    }
    
}