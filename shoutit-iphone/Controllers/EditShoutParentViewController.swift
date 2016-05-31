//
//  EditShoutParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD

final class EditShoutParentViewController: CreateShoutParentViewController {

    var shout : Shout!
    var editController : EditShoutTableViewController!
    var dismissAfter : Bool = false
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? EditShoutTableViewController {
            destination.shout = shout
            editController = destination
        }
        
        if let destination = segue.destinationViewController as? CreateShoutTableViewController {
            self.createShoutTableController = destination
            self.createShoutTableController.type = self.type
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
        
        let parameters = self.createShoutTableController.viewModel.shoutParams.encode()
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        APIShoutsService.updateShoutWithParams(parameters, uid: editController.shout.id).subscribe(onNext: { [weak self] (shout) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            
            if (self?.dismissAfter ?? false) == true{
                self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self?.navigationController?.popViewControllerAnimated(true)
            }
            
        }, onError: { [weak self] (error) -> Void in
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                self?.showError(error)
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    override func dismiss() {
        close()
    }

    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
