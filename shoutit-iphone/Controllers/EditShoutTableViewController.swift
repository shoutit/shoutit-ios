//
//  EditShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD

final class EditShoutTableViewController: CreateShoutTableViewController {

    var shout : Shout!
 
    override func createViewModel() {
        viewModel = CreateShoutViewModel(shout: shout)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillWithShoutData()
    }
    
    func fillWithShoutData() {
        headerView.titleTextField.text = shout.title
        viewModel.shoutParams.title.value = shout.title
        headerView.priceTextField.text = self.shout.priceTextWithoutFree()
        viewModel.shoutParams.price.value = self.shout.price != nil ? Double(self.shout.price! / 100) : 0.0
        downloadAttachments()
    }
    
    private func downloadAttachments() {
        
        let completionBlock: ([MediaAttachment] -> Void) = {(attachments) in
            var attachmentsDictionary = [Int : MediaAttachment]()
            for (index, attachment) in attachments.enumerate() {
                attachmentsDictionary[index] = attachment
            }
            self.imagesController?.attachments = attachmentsDictionary
            self.imagesController?.collectionView?.reloadData()
        }
        
        var attachments = [MediaAttachment]()
        
        shout.videos?.each { (video) -> () in
            attachments.append(
                MediaAttachment(
                    type: .Video,
                    uid: MediaAttachment.generateUid(),
                    remoteURL: NSURL(string: video.path),
                    thumbRemoteURL: NSURL(string: video.thumbnailPath),
                    image: nil,
                    videoDuration: Float(video.duration),
                    originalData: nil
                )
            )
        }
        
        guard let imagePaths = shout.imagePaths where imagePaths.count > 0 else {
            completionBlock(attachments)
            return
        }
        
        let queue = dispatch_queue_create("com.shoutit.editshout.photos", DISPATCH_QUEUE_CONCURRENT)
        let group = dispatch_group_create()
        
        dispatch_apply(imagePaths.count, queue) { (iteration) in
            
            dispatch_group_enter(group)
            let imgPath = imagePaths[iteration]
            let data = NSData(contentsOfURL: NSURL(string: imgPath)!)
            let image: UIImage? = data != nil ? UIImage(data: data!) : nil
            
            attachments.append(
                MediaAttachment(
                    type: .Image,
                    uid: MediaAttachment.generateUid(),
                    remoteURL: NSURL(string: imgPath),
                    thumbRemoteURL: NSURL(string: imgPath),
                    image: image,
                    videoDuration: nil,
                    originalData: data
                )
            )
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { 
            completionBlock(attachments)
        }
    }
}
