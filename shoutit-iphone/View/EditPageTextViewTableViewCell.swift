//
//  EditPageTextViewTableViewCell.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 08/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class EditPageTextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var isEditingText = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.textView.layer.borderWidth = 1.0/UIScreen.mainScreen().nativeScale
        self.textView.delegate = self
        self.textView.scrollEnabled = false
        
        self.contentView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        isEditingText = false
    }
    
    func textViewDidChange(textView: UITextView) {
        self.textViewHeight.constant = textView.contentSize.height
        self.layoutIfNeeded()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        isEditingText = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        isEditingText = false
    }
}