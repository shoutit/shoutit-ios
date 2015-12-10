//
//  SHEditProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 09/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHEditProfileTableViewModel: NSObject, SHCameraViewControllerDelegate {

    private let viewController: SHEditProfileTableViewController
    private let shApiUser = SHApiUserService()
    
    required init(viewController: SHEditProfileTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let user = self.viewController.user {
            self.loadUserData(user)
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    //Save Profile
    func save() {
        // Validate required fields
        
        self.viewController.firstNameTextField.resignFirstResponder()
        if(self.viewController.firstNameTextField.text == "") {
            self.showAlert(NSLocalizedString("First name not set", comment: "First name not set"), msgString: NSLocalizedString("Please enter firstname.", comment: "Please enter firstname."))
            return
        }
        if(!self.viewController.firstNameTextField.validate()) {
            self.viewController.firstNameTextField.tapOnError()
            return
        }
        
        self.viewController.lastNameTextField.resignFirstResponder()
        if(self.viewController.lastNameTextField.text == "") {
            self.showAlert(NSLocalizedString("Last name not set", comment: "Last name not set"), msgString: NSLocalizedString("Please enter lastname.", comment: "Please enter lastname."))
            return
        }
        if(!self.viewController.lastNameTextField.validate()) {
            self.viewController.lastNameTextField.tapOnError()
            return
        }
        
        self.viewController.usernameTextField.resignFirstResponder()
        if(self.viewController.usernameTextField.text == "") {
            self.showAlert(NSLocalizedString("Username not set", comment: "Username not set"), msgString: NSLocalizedString("Please enter username.", comment: "Please enter username."))
            return
        }
        if(!self.viewController.usernameTextField.validate()) {
            self.viewController.usernameTextField.tapOnError()
            return
        }
        
        self.viewController.emailTextField.resignFirstResponder()
        if(self.viewController.emailTextField.text == "") {
            self.showAlert(NSLocalizedString("Email not set", comment: "Email not set"), msgString: NSLocalizedString("Please enter the email.", comment: "Please enter the email."))
            return
        }
        if(!self.viewController.emailTextField.validate()) {
            self.viewController.emailTextField.tapOnError()
            return
        }
        
        self.viewController.sexTextField.resignFirstResponder()
        if(self.viewController.sexTextField.text == "") {
            self.showAlert(NSLocalizedString("Gender not set", comment: "Gender not set"), msgString: NSLocalizedString("Please select the gender.", comment: "Please select the gender."))
            return
        }
        var userDict = [String: AnyObject]()
        userDict["username"] = self.viewController.usernameTextField.text
        userDict["email"] = self.viewController.emailTextField.text
        userDict["first_name"] = self.viewController.firstNameTextField.text
        userDict["last_name"] = self.viewController.lastNameTextField.text
        userDict["bio"] = self.viewController.bioTextView.text
        userDict["gender"] = self.viewController.sexTextField.text
        
        if let username = self.viewController.user?.username {
            SHProgressHUD.show(NSLocalizedString("Updating User", comment: "Updating User"), maskType: .Black)
            shApiUser.editUser(username, userDict: userDict, cacheResponse: { (shUser) -> Void in
                SHProgressHUD.show(NSLocalizedString("User succesfully updated", comment: "User succesfully updated"), maskType: .Black)
                }) { (response) -> Void in
                    SHProgressHUD.dismiss()
                    switch(response.result) {
                    case .Success( _):
                        self.viewController.dismissViewControllerAnimated(true, completion: nil)
                    case .Failure(let error):
                        log.error("Error updating User \(error.localizedDescription)")
                    }
            }
        }
    }
    
    //Profile Pic
    func editProfilePic() {
        SHCameraViewController.presentFromViewController(self.viewController, onlyPhoto: true, timeToRecord: 0, isVideoCV: false, firstVideo: false, delegate: self)
    }
    
    func didCameraFinish(image: UIImage) {
        let media = SHMedia()
        media.isVideo = false
        media.image = image
        if let username = self.viewController.user?.username {
            shApiUser.changeUserImage(username, media: media, completionHandler: { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    log.verbose("Image updated")
                case .Failure(let error):
                    log.error("Error uploading Image")
                }
            })
        }
    }

    func didCameraFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage) {
        
    }
    
    // Private 
    private func loadUserData(user: SHUser) {
        if let username = user.username {
            shApiUser.loadUserDetails(username, cacheResponse: { (shUser) -> Void in
                self.fillUserDetails(shUser)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.fillUserDetails(result)
                    case .Failure(let error):
                        log.error("Error getting user details \(error.localizedDescription)")
                    }
            }
        }
    }
    
    private func fillUserDetails(shUser: SHUser) {
        if let image = shUser.image {
            self.viewController.profileImageView.setImageWithURL(NSURL(string: image), placeholderImage: UIImage(named: "no_image_available"), usingActivityIndicatorStyle: .White)
            self.viewController.bluredImageView.sd_setImageWithURL(NSURL(string: image))
        }
        self.viewController.firstNameTextField.text = shUser.firstName
        self.viewController.lastNameTextField.text = shUser.lastName
        self.viewController.bioTextView.text = shUser.bio
        self.viewController.usernameTextField.text = shUser.username
        self.viewController.sexTextField.text = shUser.gender
        self.viewController.emailTextField.text = shUser.email
    }
    
    private func showAlert(title: String, msgString: String) {
        let ac = UIAlertController(title: title, message: msgString, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        self.viewController.presentViewController(ac, animated: true, completion: nil)
    }

}
