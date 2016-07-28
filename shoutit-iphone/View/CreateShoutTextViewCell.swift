//
//  CreateShoutTextViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CreateShoutTextViewCell: UITableViewCell, UITextViewDelegate {
    
    private(set) var reuseDisposeBag = DisposeBag()
    @IBOutlet weak var textView: FormTextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
    
    var isEditingText = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textView.delegate = self
    }
    
    func setContent(text: String) {
        self.textView.text = text
        self.textView.invalidateIntrinsicContentSize()
        self.textViewHeight.constant = max(textView.intrinsicContentSize().height, textView.contentSize.height)
        self.layoutIfNeeded()
    }
    
    func textViewDidChange(textView: UITextView) {
        self.textViewHeight.constant = max(textView.intrinsicContentSize().height, textView.contentSize.height)
        self.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        isEditingText = false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        isEditingText = true
    }
}
