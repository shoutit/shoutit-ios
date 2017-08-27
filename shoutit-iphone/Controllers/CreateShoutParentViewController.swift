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
import ShoutitKit

class CreateShoutParentViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var createShoutTableController : CreateShoutTableViewController!
    
    var type : ShoutType!
    
    let disposeBag = DisposeBag()
    var onAppearBlock: ((Void) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(bottomConstraint)
        setTitle()
        
        if (UserDefaults.standard.bool(forKey: "createShoutLaunchedFirstTime") == false) {
            showFirstOpenAlert()
            UserDefaults.standard.set(true, forKey: "createShoutLaunchedFirstTime")
            UserDefaults.standard.synchronize()
        }
        
       
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CreateShoutParentViewController.dismiss))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppearBlock?()
        onAppearBlock = nil
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    func setTitle() {
        if self.type == .Offer {
            self.navigationItem.title = NSLocalizedString("Create Offer", comment: "Create Shout navigation item title")
        } else {
            self.navigationItem.title = NSLocalizedString("Create Request", comment: "Create Shout navigation item title")
        }
        
    }
    
    func showFirstOpenAlert() {
        
        if Account.sharedInstance.facebookManager.hasPermissions(.PublishActions) {
            return
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: "Create Shout Alert Title"), message: NSLocalizedString("Earn 1 Shoutit Credit for each shout you publicly share on Facebook", comment: "Create Shout Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: { (alertaction) in
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    override func dismiss() {
        let alert = UIAlertController(title: NSLocalizedString("Do you want to close?", comment: "Create Shout Alert Title"), message: NSLocalizedString("Are you sure? All Shout data will be lost.", comment: "Create Shout Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Create Shout Alert Option"), style: .destructive, handler: { (alertaction) in
            self.close()
        }))
            
        alert.addAction(UIAlertAction(title: NSLocalizedString("Do nothing", comment: "Create Shout Alert Option"), style: .default, handler: { (alert) in
                
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? CreateShoutTableViewController {
            self.createShoutTableController = destination
            self.createShoutTableController.type = self.type
        }
    }
    
    func attachmentsReady() -> Bool {
        
        guard let activetasks = self.createShoutTableController.imagesController?.mediaUploader.tasks else {
            return true
        }
        
        for task in activetasks {
            if task.status.value != MediaUploadingTaskStatus.uploaded {
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
                    
                    if (videos.contains{$0.path == video.path}) {
                           continue
                    }
                    
                    videos.append(video)
                }
            }
        }
        
        self.createShoutTableController.viewModel.shoutParams.images.value = urls.unique()
        self.createShoutTableController.viewModel.shoutParams.videos.value = videos
        
    }
    
    func imageAttachmentObject(_ attachment: MediaAttachment) -> String? {
        if attachment.type == .Image {
            return attachment.remoteURL?.absoluteString
        }
        
        return nil
    }

    
    func videoAttachmentObject(_ attachment: MediaAttachment) -> Video? {
        if attachment.type == .Video {
            return attachment.asVideoObject()
        }
        
        return nil
    }
    
    @IBAction func submitAction() {
        
        if attachmentsReady() == false {
            let alert = self.createShoutTableController.viewModel.mediaNotReadyAlertController()
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        assignAttachments()
        
        let parameters = self.createShoutTableController.viewModel.shoutParams.encode()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        APIShoutsService.createShoutWithParams(parameters).subscribe(onNext: { [weak self] (shout) -> Void in
            
            if let view = self?.view {
                            MBProgressHUD.hideAllHUDs(for: view, animated: true)
                        }
            
            let confirmation = Wireframe.shoutConfirmationController()
            
            confirmation.shout = shout
            
            self?.navigationController?.present(confirmation, animated: true, completion: nil)
            
            }, onError: { [weak self] (error) -> Void in
                
                if let view = self?.view {
                            MBProgressHUD.hideAllHUDs(for: view, animated: true)
                        }
                self?.showError(error)
                
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }


    @IBAction func unwindToCreateShoutParent(_ segue: UIStoryboardSegue) {
        deferCreateShoutAction()
        
    }
    
    @IBAction func unwindToEditShoutParent(_ segue: UIStoryboardSegue) {
        if let confirmation = segue.source as? ShoutConfirmationViewController {
            deferEditShoutActionWithShout(confirmation.shout)
        }
    }
    
    fileprivate func deferCreateShoutAction() {
        onAppearBlock = {[unowned self] in
            self.navigationController?.viewControllers = [Wireframe.createShoutWithTypeController(self.type)]
        }
    }
    
    fileprivate func deferEditShoutActionWithShout(_ shout: Shout) {
        onAppearBlock = {[unowned self] in
            let editController = Wireframe.editShoutController()
            editController.shout = shout
            editController.dismissAfter = true
            self.navigationController?.viewControllers = [editController]
        }
    }
}
