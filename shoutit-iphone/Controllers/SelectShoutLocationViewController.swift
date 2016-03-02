//
//  SelectShoutLocationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import FTGooglePlacesAPI

class SelectShoutLocationViewController: ChangeLocationTableViewController {

    override func finishWithCoordinates(coordinates: CLLocationCoordinate2D, place: FTGooglePlacesAPISearchResultItem) {
        if let finish = self.finishedBlock {
            finish(true, place)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
