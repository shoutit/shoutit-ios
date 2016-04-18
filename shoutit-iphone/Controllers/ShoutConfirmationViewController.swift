//
//  ShoutConfirmationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutConfirmationViewController: UIViewController {

    var shout : Shout!
    
    @IBOutlet weak var createAnotherButton: CustomUIButton!
    @IBOutlet weak var descriptionlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shout.type()! == ShoutType.Offer {
            createAnotherButton.setTitle(NSLocalizedString("Create another Offer", comment: ""), forState: .Normal)
            if let title = shout.title {
                descriptionlabel.text = NSLocalizedString("Your offer \"\(title)\" will appear on Shoutit soon.", comment:"")
            } else {
                descriptionlabel.text = NSLocalizedString("Your offer will appear on Shoutit soon.", comment:"")
            }
            
        } else {
            createAnotherButton.setTitle(NSLocalizedString("Create another Request", comment: ""), forState: .Normal)
            if let title = shout.title {
                descriptionlabel.text = NSLocalizedString("Your request \"\(title)\" will appear on Shoutit soon.", comment:"")
            } else {
                descriptionlabel.text = NSLocalizedString("Your request will appear on Shoutit soon.", comment:"")
            }
        }
    }
}
