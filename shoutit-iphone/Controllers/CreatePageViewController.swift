//
//  CreatePageViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreatePageViewController: UIViewController {
    
    // navigation
    weak var flowDelegate: LoginFlowController?
    
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
