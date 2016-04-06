//
//  EditShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditShoutTableViewController: CreateShoutTableViewController {

    var shout : Shout!
 
    override func createViewModel() {
        viewModel = CreateShoutViewModel(shout: shout)
        viewModel.showFilters = true
        viewModel.showType = false
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillWithShoutData()
    }
    
    func fillWithShoutData() {
        self.headerView.titleTextField.text = self.shout.title
        self.viewModel.shoutParams.title.value = self.shout.title
 
        self.headerView.priceTextField.text = self.shout.priceText()
        self.viewModel.shoutParams.price.value = self.shout.price != nil ? Double(self.shout.price! / 100) : 0.0
        
        var attachments : [Int : MediaAttachment] = [:]
        var idx = 0
        
        self.shout.imagePaths?.each({ (imgPath) -> () in
            attachments[idx] = MediaAttachment(type: .Image, image: nil, originalData: nil, remoteURL: NSURL(string:imgPath), thumbRemoteURL: NSURL(string:imgPath), uid: MediaAttachment.generateUid(), videoDuration: nil)
            idx += 1
        })
        
        self.shout.videos?.each({ (video) -> () in
            attachments[idx] = MediaAttachment(type: .Video, image: nil, originalData: nil, remoteURL: NSURL(string: video.path), thumbRemoteURL: NSURL(string: video.thumbnailPath), uid: MediaAttachment.generateUid(), videoDuration: Float(video.duration))
            idx += 1
        })
        
        self.imagesController?.attachments = attachments;
        self.imagesController?.collectionView?.reloadData()
    }
    
}
