//
//  DiscoverPreviewParentController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class DiscoverPreviewParentController: UIViewController {
    
    var discoverController : DiscoverPreviewCollectionViewController?
    @IBOutlet weak var titleLabel : UILabel?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let discover = segue.destinationViewController as? DiscoverPreviewCollectionViewController {
            discoverController = discover
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
}
