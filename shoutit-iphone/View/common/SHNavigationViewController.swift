//
//  SHNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHNavigation: NSObject { //UINavigationController

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    func viewControllerWithId(viewControllerId: String) -> AnyObject {
        return viewControllerFromStoryboard(viewControllerId, withViewControllerId: viewControllerId)
    }
    
    func viewControllerFromStoryboard(storyboardName: String, withViewControllerId viewControllerId: String) -> AnyObject {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(viewControllerId)
    }
    
    func storyboard(storyboardName: String) -> AnyObject {
        return UIStoryboard(name: storyboardName, bundle: nil)
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
