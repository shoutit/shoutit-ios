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
 
        self.headerView.priceTextField.text = self.shout.priceTextWithoutFree()
        self.viewModel.shoutParams.price.value = self.shout.price != nil ? Double(self.shout.price! / 100) : 0.0
        
        var attachments : [Int : MediaAttachment] = [:]
        var idx = 0
        
        self.shout.imagePaths?.each{ (imgPath) -> () in
            attachments[idx] = MediaAttachment(
                type: .Image,
                uid: MediaAttachment.generateUid(),
                remoteURL: NSURL(string:imgPath),
                thumbRemoteURL: NSURL(string:imgPath),
                image: nil,
                videoDuration: nil,
                originalData: nil
            )
            idx += 1
        }
        
        self.shout.videos?.each{ (video) -> () in
            attachments[idx] = MediaAttachment(
                type: .Video,
                uid: MediaAttachment.generateUid(),
                remoteURL: NSURL(string: video.path),
                thumbRemoteURL: NSURL(string: video.thumbnailPath),
                image: nil,
                videoDuration: Float(video.duration),
                originalData: nil
            )
            idx += 1
        }
        
        self.imagesController?.attachments = attachments;
        self.imagesController?.collectionView?.reloadData()
    }
    
}
