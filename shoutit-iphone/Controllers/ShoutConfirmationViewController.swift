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
    
    @IBAction func editShoutAction(sender: AnyObject) {
        let editController = Wireframe.editShoutController()
        editController.shout = shout
        
        self.navigationController?.viewControllers = [Wireframe.shoutViewController()]
        self.navigationController?.pushViewController(editController, animated: true)
        
    }
    
    @IBAction func createNewShoutAction(sender: AnyObject) {
        self.navigationController?.viewControllers = [Wireframe.shoutViewController(), self]
        self.navigationController?.popViewControllerAnimated(true)
    }
}
