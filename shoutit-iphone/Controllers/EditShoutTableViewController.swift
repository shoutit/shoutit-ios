//
//  EditShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD
import ShoutitKit

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
    
    fileprivate func downloadAttachments() {
        
        let completionBlock: (([MediaAttachment]) -> Void) = {(attachments) in
            var attachmentsDictionary = [Int : MediaAttachment]()
            for (index, attachment) in attachments.enumerated() {
                attachmentsDictionary[index] = attachment
            }
            self.imagesController?.attachments = attachmentsDictionary
            self.imagesController?.collectionView?.reloadData()
        }
        
        var attachments = [MediaAttachment]()
        
        shout.videos?.each { (video) -> () in
            attachments.append(
                MediaAttachment(
                    type: .video,
                    uid: MediaAttachment.generateUid(),
                    remoteURL: URL(string: video.path),
                    thumbRemoteURL: URL(string: video.thumbnailPath),
                    image: nil,
                    videoDuration: Float(video.duration),
                    originalData: nil
                )
            )
        }
        
        guard let imagePaths = shout.imagePaths, imagePaths.count > 0 else {
            completionBlock(attachments)
            return
        }
        
        let queue = DispatchQueue(label: "com.shoutit.editshout.photos", attributes: DispatchQueue.Attributes.concurrent)
        let group = DispatchGroup()
        
        DispatchQueue.concurrentPerform(iterations: imagePaths.count) { (iteration) in
            
            group.enter()
            let imgPath = imagePaths[iteration]
            let data = try? Data(contentsOf: URL(string: imgPath)!)
            let image: UIImage? = data != nil ? UIImage(data: data!) : nil
            
            attachments.append(
                MediaAttachment(
                    type: .image,
                    uid: MediaAttachment.generateUid(),
                    remoteURL: URL(string: imgPath),
                    thumbRemoteURL: URL(string: imgPath),
                    image: image,
                    videoDuration: nil,
                    originalData: data
                )
            )
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) { 
            completionBlock(attachments)
        }
    }
}
