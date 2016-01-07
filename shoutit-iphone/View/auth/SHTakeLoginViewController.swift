//
//  SHTakeLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTakeLoginViewController: UIViewController {

    @IBOutlet weak var welcomeTextSpaceFromLogo: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        // 667/8.3375 = 80 as per zeplin designs we have top space of 80, lets keep it properly according to aspect ratio
        welcomeTextSpaceFromLogo.constant = UIScreen.mainScreen().bounds.height / 8.3375
    }
    
    
    @IBAction func skipLogin(sender: AnyObject) {
        SHOauthToken.goToDiscover()
    }

}
