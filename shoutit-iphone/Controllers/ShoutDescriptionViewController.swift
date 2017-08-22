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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowUp), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShowUp(_ notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.bottomTextViewConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }) 
        
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomTextViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) 
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.completionSubject.onNext(textView.text)
    }
    
    @IBAction func save() {
        self.textView.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
}
