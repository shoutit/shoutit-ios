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
        self.viewModel.shoutParams.price.value = self.shout.price
        
        var attachments : [Int : MediaAttachment] = [:]
        var idx = 0
        
        self.shout.imagePaths?.each({ (imgPath) -> () in
            attachments[idx] = MediaAttachment(type: .Image, image: nil, originalData: nil, remoteURL: NSURL(string:imgPath), thumbRemoteURL: nil, uid: MediaAttachment.generateUid())
            idx += 1
        })
        
        self.imagesController?.attachments = attachments;
        self.imagesController?.collectionView?.reloadData()
    }
    
    override func submitAction() {
        if attachmentsReady() == false {
            let alert = viewModel.mediaNotReadyAlertController()
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        assignAttachments()
        
        let parameters = viewModel.shoutParams.encode().JSONObject() as! [String : AnyObject]
        
        print(parameters)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        APIShoutsService.updateShoutWithParams(parameters, uid: self.shout.id).subscribe(onNext: { [weak self] (shout) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            
            self?.navigationController?.popViewControllerAnimated(true)
            
            }, onError: { [weak self] (error) -> Void in
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                
                let alertController = UIAlertController(title: NSLocalizedString((error as NSError!).localizedDescription, comment: ""), message: "", preferredStyle: .Alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
                
                self?.navigationController?.presentViewController(alertController, animated: true, completion: nil)
                
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
}
