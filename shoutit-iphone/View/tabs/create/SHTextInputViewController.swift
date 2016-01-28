//
//  SHTextInputViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTextInputViewController: UIViewController, UITextViewDelegate {

    var completion: ((text: String) -> ())?
    @IBOutlet weak var textView: UITextView!
    
    private var text = String()
    private var initialText = String()
    private let limit: Int = 1000
    private let minLimit: Int = 10
    private var countLabel: UILabel!
    private var originalTextViewFrame: CGRect?
    
    static func presentFromViewController(parent: UIViewController, text: String, completionHandler: ((text: String) -> ())) {
        let textVC = UIStoryboard.getCreateShout().instantiateViewControllerWithIdentifier("SHTextInputViewController") as! SHTextInputViewController
        textVC.title = NSLocalizedString("Input Description", comment: "Input Description")
        textVC.completion = completionHandler
        textVC.text = text
        textVC.initialText = text
        let navVC = SHNavigationViewController(rootViewController: textVC)
        parent.presentViewController(navVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .Done, target: self, action: "doneAction:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Done, target: self, action: "cancelAction:")
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.sizeToFit()
        
        self.textView.text = self.text
        
        self.countLabel = UILabel(frame: CGRectMake(0, 0, 100, 44))
        self.countLabel.backgroundColor = UIColor.clearColor()
        self.countLabel.font = UIFont(name: "Helvetica-light", size: 15)
        self.countLabel.text = String(format: "%d - %d", self.textView.text.characters.count - self.minLimit, self.limit - self.textView.text.characters.count)
        if self.textView.text.characters.count > self.limit - 20 || self.textView.text.characters.count - self.minLimit < 0 {
            self.countLabel.textColor = UIColor.redColor()
        } else {
            self.countLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
        }
        
        let item = UIBarButtonItem(customView: self.countLabel)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleItem, item]
        
        self.textView.inputAccessoryView = toolbar
        self.countLabel.sizeToFit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func doneAction(sender: AnyObject?) {
        self.completion?(text: self.textView.text)
        self.textView.resignFirstResponder()
        if self.textView.text.characters.count < self.minLimit {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Text length should be more than 10 characters.", comment: "Text length should be more than 10 characters."), preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .Cancel) { (action) in
                // Do Nothing
            }
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func cancelAction(sender: AnyObject?) {
        var txt = ""
        if !self.initialText.isEmpty {
            txt = self.initialText
        }
        self.completion?(text: txt)
        self.textView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        self.moveTextViewForKeyboard(notification, up: true)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.moveTextViewForKeyboard(notification, up: false)
    }
    
    func moveTextViewForKeyboard(notification: NSNotification, up: Bool) {
        var animationCurve: UIViewAnimationCurve = .Linear
        if let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve {
            animationCurve = curve
        }
        
        var animationDuration: Double = 0
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            animationDuration = duration
        }
        
        var keyboardRect: CGRect = CGRectZero
        if let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            keyboardRect = rect
        }
        keyboardRect = self.view.convertRect(keyboardRect, fromView: nil)
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        if up {
            let keyboardTop = keyboardRect.origin.y
            var newTextViewFrame = self.textView.frame
            self.originalTextViewFrame = self.textView.frame
            newTextViewFrame.size.height = keyboardTop - self.textView.frame.origin.y - 10
        } else {
            if let frame = self.originalTextViewFrame {
                self.textView.frame = frame
            }
        }
        UIView.commitAnimations()
    }
    
    // MARK - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let len = textView.text.characters.count + (text.characters.count - range.length)
        
        self.countLabel.text = String(format: "%d - %d", len - self.minLimit, self.limit - len)
        
        if len > self.limit - 20 || len - self.minLimit < 0 {
            self.countLabel.textColor = UIColor.redColor()
        } else {
            self.countLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
        }
        self.countLabel.sizeToFit()
        return len < self.limit
    }

}
