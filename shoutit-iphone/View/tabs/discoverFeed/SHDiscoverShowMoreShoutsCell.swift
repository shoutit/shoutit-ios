//
//  SHDiscoverShowMoreShoutsCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/6/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShowMoreShoutsCell: UICollectionViewCell {
    private var discoverFeedViewController : SHDiscoverFeedViewController?
    
    @IBAction func seeAllShoutsAction(sender: AnyObject) {
        if let viewController = self.discoverFeedViewController {
            let discoverShoutsVC = UIStoryboard.getDiscover().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHDISCOVERSHOUTS) as! SHDiscoverShoutsViewController
            discoverShoutsVC.discoverId = viewController.discoverId
            viewController.navigationController?.pushViewController(discoverShoutsVC, animated: true)
        }
    }
    
    func setup(viewController: SHDiscoverFeedViewController) {
        self.discoverFeedViewController = viewController
    }
}
