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
        
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1.0/UIScreen.main.nativeScale
        self.textView.delegate = self
        
        self.textView.contentInset = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
        
        self.contentView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        isEditingText = false
    }
    
    func setContent(_ text: String) {
        self.textView.text = text
        self.textView.invalidateIntrinsicContentSize()
        self.textViewHeight.constant = max(textView.intrinsicContentSize.height, textView.contentSize.height) + (text.characters.count > 0 ? 10.0 : 0)
        self.layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textViewHeight.constant = textView.contentSize.height
        self.layoutIfNeeded()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditingText = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditingText = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.utf16.count < 150 || text.utf16.count == 0
    }
}
