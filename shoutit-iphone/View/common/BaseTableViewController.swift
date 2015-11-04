//
//  BaseTableViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "endEditing")
        self.view.addGestureRecognizer(tapGesture)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        endEditing()
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    func initializeViewModel() {
        assertionFailure("You must override this method in child class [e.g - \nviewModel = ClubFeedViewModel(viewController: self)\n]")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK - Keyboard Notification
    func keyboardWillShow(notification: NSNotification) {
        assertionFailure("You must override this method in child class")
    }
    
    func keyboardWillHide(notification: NSNotification) {
        assertionFailure("You must override this method in child class")
    }
}

