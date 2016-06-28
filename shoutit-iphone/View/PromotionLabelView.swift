//
//  PromotionLabelView.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

class PromotionLabelView: UIView {
    
    @IBOutlet weak var sentenceLabel : UILabel?
    @IBOutlet weak var topLabel : UILabel?
    @IBOutlet weak var topLabelBackground : UIView?
    @IBOutlet weak var daysLeftLabel: UILabel?
    @IBOutlet weak var backgroundView : UIView?
    
    class func instanceFromNib() -> PromotionLabelView {
        return UINib(nibName: "PromotionLabelView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PromotionLabelView
    }

    func bindWithPromotionLabel(label: PromotionLabel) {
        self.sentenceLabel?.text = label.description
        self.topLabel?.text = label.name
        self.topLabelBackground?.backgroundColor = label.color()
        self.backgroundView?.backgroundColor = label.backgroundUIColor()
    }

}