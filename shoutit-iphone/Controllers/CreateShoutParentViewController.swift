//
//  CreateShoutParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxSwift

class CreateShoutParentViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var createShoutTableController : CreateShoutTableViewController!
    
    var type : ShoutType!
    
    let disposeBag = DisposeBag()
    var onAppearBlock: (Void -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(bottomConstraint)
        setTitle()
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("createShoutLaunchedFirstTime") == false) {
            showFirstOpenAlert()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "createShoutLaunchedFirstTime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
       
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(CreateShoutParentViewController.dismiss))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        onAppearBlock?()
        onAppearBlock = nil
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    func setTitle() {
        if self.type == .Offer {
            self.navigationItem.title = NSLocalizedString("Create Offer", comment: "")
        } else {
            self.navigationItem.title = NSLocalizedString("Create Request", comment: "")
        }
        
    }
    
    func showFirstOpenAlert() {
        
        if Account.sharedInstance.facebookManager.hasPermissions(.PublishActions) {
            return
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: ""), message: NSLocalizedString("Earn 1 Shoutit Credit for each shout you publicly share on Facebook", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (alertaction) in
            self.close()
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func dismiss() {
        let alert = UIAlertController(title: NSLocalizedString("Do you want to close?", comment: ""), message: NSLocalizedString("Are you sure? All Shout data will be lost.", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .Destructive, handler: { (alertaction) in
            self.close()
        }))
            
        alert.addAction(UIAlertAction(title: NSLocalizedString("Do nothing", comment: ""), style: .Default, handler: { (alert) in
                
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func close() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destinationViewController as? CreateShoutTableViewController {
            self.createShoutTableController = destination
            self.createShoutTableController.type = self.type
        }
    }
    
    func attachmentsReady() -> Bool {
        
        guard let activetasks = self.createShoutTableController.imagesController?.mediaUploader.tasks else {
            return true
        }
        
        for task in activetasks {
            if task.status.value != MediaUploadingTaskStatus.Uploaded {
                return false
            }
        }
        
        return true
        
    }
    
    func assignAttachments() {
        guard let attachments = self.createShoutTableController.imagesController?.attachments else {
            return
        }
        
        var urls : [String] = []
        var videos : [Video] = []
        
        for (_, attachment) in attachments {
            if let path = imageAttachmentObject(attachment) {
                urls.append(path)
            }
            if let video = videoAttachmentObject(attachment) {
                videos.append(video)
            }
        }
        
        if let activeTasks = self.createShoutTableController.imagesController?.mediaUploader.tasks {
            for task in activeTasks {
                if let path = imageAttachmentObject(task.attachment) {
                    urls.append(path)
                }
                if let video = videoAttachmentObject(task.attachment) {
                    videos.append(video)
                }
            }
        }
        
        self.createShoutTableController.viewModel.shoutParams.images.value = urls.unique()
        self.createShoutTableController.viewModel.shoutParams.videos.value = videos
        
    }
    
    func imageAttachmentObject(attachment: MediaAttachment) -> String? {
        if attachment.type == .Image {
            return attachment.remoteURL?.absoluteString
        }
        
        return nil
    }

    
    func videoAttachmentObject(attachment: MediaAttachment) -> Video? {
        if attachment.type == .Video {
            return attachment.asVideoObject()
        }
        
        return nil
    }
    
    @IBAction func submitAction() {
        
        if attachmentsReady() == false {
            let alert = self.createShoutTableController.viewModel.mediaNotReadyAlertController()
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        assignAttachments()
        
        let parameters = self.createShoutTableController.viewModel.shoutParams.encode()
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        APIShoutsService.createShoutWithParams(parameters).subscribe(onNext: { [weak self] (shout) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            
            let confirmation = Wireframe.shoutConfirmationController()
            
            confirmation.shout = shout
            
            self?.navigationController?.presentViewController(confirmation, animated: true, completion: nil)
            
            }, onError: { [weak self] (error) -> Void in
                
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                self?.showError(error)
                
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }


    @IBAction func unwindToCreateShoutParent(segue: UIStoryboardSegue) {
        deferCreateShoutAction()
        
    }
    
    @IBAction func unwindToEditShoutParent(segue: UIStoryboardSegue) {
        if let confirmation = segue.sourceViewController as? ShoutConfirmationViewController {
            deferEditShoutActionWithShout(confirmation.shout)
        }
    }
    
    private func deferCreateShoutAction() {
        onAppearBlock = {[unowned self] in
            self.navigationController?.viewControllers = [Wireframe.createShoutWithTypeController(self.type)]
        }
    }
    
    private func deferEditShoutActionWithShout(shout: Shout) {
        onAppearBlock = {[unowned self] in
            let editController = Wireframe.editShoutController()
            editController.shout = shout
            editController.dismissAfter = true
            self.navigationController?.viewControllers = [editController]
        }
    }
}
