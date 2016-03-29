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
            createAnotherButton.setTitle("Create another Offer", forState: .Normal)
            descriptionlabel.text = NSLocalizedString("Your offer will appear on Shoutit soon.", comment:"")
        } else {
            createAnotherButton.setTitle("Create another Request", forState: .Normal)
            descriptionlabel.text = NSLocalizedString("Your request will appear on Shoutit soon.", comment:"")
        }
    }
}
