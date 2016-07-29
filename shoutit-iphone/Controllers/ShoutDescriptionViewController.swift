//
//  ShoutDescriptionViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ShoutDescriptionViewController: UIViewController , UITextViewDelegate {

    @IBOutlet weak var textView : UITextView!
    @IBOutlet var bottomTextViewConstraint : NSLayoutConstraint!
    var initialText : String?
    
    let completionSubject: PublishSubject<String?> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        self.title = NSLocalizedString("Shout Description", comment: "")
        
        applyBackButton()
        
        self.textView.text = initialText
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShowUp), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowUp(notification: NSNotification) {
        guard let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect, duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
            return
        }
        
        UIView.animateWithDuration(duration) {
            self.bottomTextViewConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3) {
            self.bottomTextViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.completionSubject.onNext(textView.text)
    }
    
    @IBAction func save() {
        self.textView.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
    }
}
