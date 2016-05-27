//
//  CreateShoutTextViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CreateShoutTextViewCell: UITableViewCell {
    
    private(set) var reuseDisposeBag = DisposeBag()
    @IBOutlet weak var textView: FormTextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
