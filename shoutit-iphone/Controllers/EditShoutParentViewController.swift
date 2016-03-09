//
//  EditShoutParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditShoutParentViewController: CreateShoutParentViewController {

    var shout : Shout!
    var editController : EditShoutTableViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? EditShoutTableViewController {
            destination.shout = shout
            editController = destination
        }
    }
    
    override func setTitle() {
        if self.shout.type() == .Offer {
            self.navigationItem.title = NSLocalizedString("Edit Offer", comment: "")
        } else {
            self.navigationItem.title = NSLocalizedString("Edit Request", comment: "")
        }
    }
    
    override func submitAction() {
        
        if attachmentsReady() == false {
            let alert = self.createShoutTableController.viewModel.mediaNotReadyAlertController()
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        assignAttachments()
        
        let parameters = self.createShoutTableController.viewModel.shoutParams.encode().JSONObject() as! [String : AnyObject]
        
        print(parameters)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        APIShoutsService.updateShoutWithParams(parameters, uid: editController.shout.id).subscribe(onNext: { [weak self] (shout) -> Void in
            
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
