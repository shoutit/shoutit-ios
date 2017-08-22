//
//  PhotosMenuController.swift
//  Nemo
//
//  Created by Sinoru on 2015. 8. 8..
//  Copyright (c) 2015년 Sinoru. All rights reserved.
//

import UIKit
import MobileCoreServices

/// PhotosMenuController is a menu for photo picking. Like as Message.app's one. It includes recently photo section to easily select multiple photos.
@objc(NMPhotosMenuController)
open class PhotosMenuController: UIAlertController {

    /// The photo menu’s delegate object.
    open weak var delegate: (PhotosMenuControllerDelegate & UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    /// An array indicating the media types to be accessed by the media picker controller.
    open var mediaTypesForImagePicker: [String] = [kUTTypeImage as String] {
        didSet {
            self.updateCameraActionTitle()
        }
    }
    
    fileprivate var recentPhotosCollectionViewController: RecentPhotosCollectionViewController!
    
    fileprivate var photoLibraryAction: UIAlertAction!
    fileprivate var cameraAction: UIAlertAction!
    fileprivate var cancelAction: UIAlertAction!
    fileprivate var customActions: Array<UIAlertAction> = []
    
    fileprivate weak var capturedPresentingViewController: UIViewController?
    fileprivate var capturedPopoverPresentationControllerBarButtonItem: UIBarButtonItem?
    fileprivate var capturedPopoverPresentationControllerSourceView: UIView?
    fileprivate var capturedPopoverPresentationControllerSourceRect: CGRect?
    
    /// Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.recentPhotosCollectionViewController = RecentPhotosCollectionViewController()
        self.recentPhotosCollectionViewController.preferredContentSize = CGSize(width: 0.0, height: 172.0)
        self.recentPhotosCollectionViewController.delegate = self
        
        self.photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Pick Photot Option TItle"), style: .default, handler: { (action) -> Void in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self.delegate
            imagePickerController.modalPresentationStyle = .popover
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = self.mediaTypesForImagePicker
            
            imagePickerController.popoverPresentationController?.barButtonItem = self.capturedPopoverPresentationControllerBarButtonItem
            imagePickerController.popoverPresentationController?.sourceView = self.capturedPopoverPresentationControllerSourceView
            imagePickerController.popoverPresentationController?.sourceRect = self.capturedPopoverPresentationControllerSourceRect ?? CGRect.zero
            
            self.delegate?.photosMenuController?(self, didPickImagePicker: imagePickerController)
            
            self.capturedPresentingViewController?.present(imagePickerController, animated: true, completion: nil)
        })
        
        self.cameraAction = UIAlertAction(title: NSLocalizedString("Take Photo or Video", comment: "Pick Photot Option TItle"), style: .default, handler: { (action) -> Void in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self.delegate
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = self.mediaTypesForImagePicker
            
            self.delegate?.photosMenuController?(self, didPickImagePicker: imagePickerController)
            
            self.capturedPresentingViewController?.present(imagePickerController, animated: true, completion: nil)
        })
        self.updateCameraActionTitle()
        
        self.cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel,  handler: { (action) -> Void in
            self.delegate?.photosMenuControllerDidCancel?(self)
        })
    }
    
    /// Called when the view is about to made visible.
    open override func viewWillAppear(_ animated: Bool) {
        self.setValue(self.recentPhotosCollectionViewController, forKey: "contentViewController")
        super.addAction(self.recentPhotosCollectionViewController.addPhotoAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            super.addAction(self.photoLibraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            super.addAction(self.cameraAction)
        }
        
        for action in customActions {
            super.addAction(action)
        }
        
        super.addAction(self.cancelAction)
        
        super.viewWillAppear(animated)
        
        self.capturedPresentingViewController = self.presentingViewController
        self.capturedPopoverPresentationControllerBarButtonItem = self.popoverPresentationController?.barButtonItem
        self.capturedPopoverPresentationControllerSourceRect = self.popoverPresentationController?.sourceRect
        self.capturedPopoverPresentationControllerSourceView = self.popoverPresentationController?.sourceView
    }
    
    /**
    Attaches an action object to the alert or action sheet.
    
    :param: action The action object to display as part of the alert.
    */
    open override func addAction(_ action: UIAlertAction) {
        customActions += [action]
    }
    
    fileprivate func updateCameraActionTitle() {
        let cameraActionTitle: String
        
        let mediaTypesContainImage = (self.mediaTypesForImagePicker.index(of: (kUTTypeImage as String)) != nil)
        let mediaTypesContainMovie = (self.mediaTypesForImagePicker.index(of: (kUTTypeMovie as String)) != nil)
        
        if mediaTypesContainImage && mediaTypesContainMovie {
            cameraActionTitle = NSLocalizedString("Take Photo or Video", comment: "Pick Photot Option Title")
        }
        else if mediaTypesContainImage {
            cameraActionTitle = NSLocalizedString("Take Photo", comment: "Pick Photot Option Title")
        }
        else if mediaTypesContainMovie {
            cameraActionTitle = NSLocalizedString("Take Video", comment: "Pick Photot Option Title")
        }
        else {
            cameraActionTitle = NSLocalizedString("Take Photo or Video", comment: "Pick Photot Option Title")
        }
        
        self.cameraAction.setValue(cameraActionTitle, forKey: "title")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotosMenuController: RecentPhotosCollectionViewControllerDelegate {
    func recentPhotosCollectionViewController(_ controller: RecentPhotosCollectionViewController, didFinishPickingPhotos photos: [PHAsset]) {
        self.delegate?.photosMenuController?(self, didPickPhotos: photos)
    }
}
