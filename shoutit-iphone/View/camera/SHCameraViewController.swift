//
//  SHCameraViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHCameraViewController: SHCameraControlViewController {

    @IBOutlet var gestureRecognizers: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleMovieRecording(sender: AnyObject) {
    }
    
    @IBAction func changeCamera(sender: AnyObject) {
    }
    
    @IBAction func snapStillImage(sender: AnyObject) {
    }
    
}
