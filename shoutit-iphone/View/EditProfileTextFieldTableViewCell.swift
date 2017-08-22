//
//  EditProfileTextFieldTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class EditProfileTextFieldTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textField: BorderedMaterialTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.titleLabel = UILabel()
        textField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .medium)
        textField.titleLabelColor = UIColor(shoutitColor: .discoverBorder)
        textField.titleLabelActiveColor = UIColor(shoutitColor: .shoutitLightBlueColor)
        textField.clearButtonMode = .whileEditing
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
