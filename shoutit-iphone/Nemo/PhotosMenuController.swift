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
public class PhotosMenuController: UIAlertController {

    /// The photo menu’s delegate object.
    public var delegate: protocol<PhotosMenuControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>?
    
    /// An array indicating the media types to be accessed by the media picker controller.
    public var mediaTypesForImagePicker: [String] = [kUTTypeImage as String] {
        didSet {
            self.updateCameraActionTitle()
        }
    }
    
    private var recentPhotosCollectionViewController: RecentPhotosCollectionViewController!
    
    private var photoLibraryAction: UIAlertAction!
    private var cameraAction: UIAlertAction!
    private var cancelAction: UIAlertAction!
    private var customActions: Array<UIAlertAction> = []
    
    private var capturedPresentingViewController: UIViewController?
    private var capturedPopoverPresentationControllerBarButtonItem: UIBarButtonItem?
    private var capturedPopoverPresentationControllerSourceView: UIView?
    private var capturedPopoverPresentationControllerSourceRect: CGRect?
    
    /// Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.recentPhotosCollectionViewController = RecentPhotosCollectionViewController()
        self.recentPhotosCollectionViewController.preferredContentSize = CGSize(width: 0.0, height: 172.0)
        self.recentPhotosCollectionViewController.delegate = self
        
        self.photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .Default, handler: { (action) -> Void in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self.delegate
            imagePickerController.modalPresentationStyle = .Popover
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.mediaTypes = self.mediaTypesForImagePicker
            
            imagePickerController.popoverPresentationController?.barButtonItem = self.capturedPopoverPresentationControllerBarButtonItem
            imagePickerController.popoverPresentationController?.sourceView = self.capturedPopoverPresentationControllerSourceView
            imagePickerController.popoverPresentationController?.sourceRect = self.capturedPopoverPresentationControllerSourceRect ?? CGRectZero
            
            self.delegate?.photosMenuController?(self, didPickImagePicker: imagePickerController)
            
            self.capturedPresentingViewController?.presentViewController(imagePickerController, animated: true, completion: nil)
        })
        
        self.cameraAction = UIAlertAction(title: NSLocalizedString("Take Photo or Video", comment: ""), style: .Default, handler: { (action) -> Void in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self.delegate
            imagePickerController.modalPresentationStyle = .FullScreen
            imagePickerController.sourceType = .Camera
            imagePickerController.mediaTypes = self.mediaTypesForImagePicker
            
            self.delegate?.photosMenuController?(self, didPickImagePicker: imagePickerController)
            
            self.capturedPresentingViewController?.presentViewController(imagePickerController, animated: true, completion: nil)
        })
        self.updateCameraActionTitle()
        
        self.cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel,  handler: { (action) -> Void in
            self.delegate?.photosMenuControllerDidCancel?(self)
        })
    }
    
    /// Called when the view is about to made visible.
    public override func viewWillAppear(animated: Bool) {
        self.setValue(self.recentPhotosCollectionViewController, forKey: "contentViewController")
        super.addAction(self.recentPhotosCollectionViewController.addPhotoAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            super.addAction(self.photoLibraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
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
    public override func addAction(action: UIAlertAction) {
        customActions += [action]
    }
    
    private func updateCameraActionTitle() {
        let cameraActionTitle: String
        
        let mediaTypesContainImage = (self.mediaTypesForImagePicker.indexOf((kUTTypeImage as String)) != nil)
        let mediaTypesContainMovie = (self.mediaTypesForImagePicker.indexOf((kUTTypeMovie as String)) != nil)
        
        if mediaTypesContainImage && mediaTypesContainMovie {
            cameraActionTitle = NSLocalizedString("Take Photo or Video", comment: "")
        }
        else if mediaTypesContainImage {
            cameraActionTitle = NSLocalizedString("Take Photo", comment: "")
        }
        else if mediaTypesContainMovie {
            cameraActionTitle = NSLocalizedString("Take Video", comment: "")
        }
        else {
            cameraActionTitle = NSLocalizedString("Take Photo or Video", comment: "")
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
    func recentPhotosCollectionViewController(controller: RecentPhotosCollectionViewController, didFinishPickingPhotos photos: [PHAsset]) {
        self.delegate?.photosMenuController?(self, didPickPhotos: photos)
    }
}
