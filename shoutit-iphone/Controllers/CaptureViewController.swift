//
//  CaptureViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Nemo
import MobileCoreServices

class CaptureViewController: PhotosMenuController {

    override var mediaTypesForImagePicker: [String] {
        get {
            return [kUTTypeImage as String, kUTTypeMovie as String]
        }
        set {
            
        }
    }
    
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
