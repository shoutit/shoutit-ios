//
//  EditPageTextFieldTableViewCell.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 08/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class EditPageTextFieldTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textField: BorderedMaterialTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.titleLabel = UILabel()
        textField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textField.titleLabelColor = UIColor(shoutitColor: .DiscoverBorder)
        textField.titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        textField.clearButtonMode = .WhileEditing
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
