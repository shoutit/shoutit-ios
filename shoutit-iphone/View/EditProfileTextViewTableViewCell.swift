//
//  EditProfileTextViewTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class EditProfileTextViewTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textView: BorderedMaterialTextView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.placeholderLabel = UILabel()
        textView.placeholderLabel!.font = UIFont.sh_systemFontOfSize(18, weight: .Regular)
        textView.placeholderLabel!.textColor = UIColor(shoutitColor: .PlaceholderGray)
        
        textView.titleLabel = UILabel()
        textView.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textView.titleLabelColor = UIColor(shoutitColor: .DiscoverBorder)
        textView.titleLabelActiveColor = UIColor(shoutitColor: .TextFieldLightBlueColor)
        
        textView.detailLabel = UILabel()
        textView.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textView.detailLabelActiveColor = UIColor(shoutitColor: .DiscoverBorder)
        textView.detailLabelHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
