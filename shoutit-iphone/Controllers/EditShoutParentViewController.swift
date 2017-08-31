//
//  EditShoutParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD
import ShoutitKit
import JSONCodable

final class EditShoutParentViewController: CreateShoutParentViewController {

    var shout : Shout!
    var editController : EditShoutTableViewController!
    var dismissAfter : Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditShoutTableViewController {
            destination.shout = shout
            editController = destination
        }
        
        if let destination = segue.destination as? CreateShoutTableViewController {
            self.createShoutTableController = destination
            self.createShoutTableController.type = self.type
        }

    }
    
    override func setTitle() {
        if self.shout.type() == .Offer {
            self.navigationItem.title = NSLocalizedString("Edit Offer", comment: "Edit Shout Navigation Item Title")
        } else {
            self.navigationItem.title = NSLocalizedString("Edit Request", comment: "Edit Shout Navigation Item Title")
        }
    }
    
    override func submitAction() {
        
        if attachmentsReady() == false {
            let alert = self.createShoutTableController.viewModel.mediaNotReadyAlertController()
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        assignAttachments()
        
        guard let parameters = try? self.createShoutTableController.viewModel.shoutParams.toJSON() else {
            assertionFailure("could not serialize parameters")
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        APIShoutsService.updateShoutWithParams(parameters as! JSONObject, uid: editController.shout.id).subscribe(onNext: { [weak self] (shout) -> Void in
            
            if let view = self?.view {
                            MBProgressHUD.hideAllHUDs(for: view, animated: true)
                        }
            
            if (self?.dismissAfter ?? false) == true{
                self?.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
            
        }, onError: { [weak self] (error) -> Void in
                if let view = self?.view {
                            MBProgressHUD.hideAllHUDs(for: view, animated: true)
                        }
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
