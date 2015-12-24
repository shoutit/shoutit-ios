//
//  SHShoutMyFeedHeaderCellViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutMyFeedHeaderCellViewModel: NSObject {

    private let cell: SHShoutMyFeedHeaderCell
    private var viewController: SHShoutListViewController?
    
    init(cell: SHShoutMyFeedHeaderCell) {
        self.cell = cell
    }
    
    func setUp(viewController: SHShoutListViewController?) {
        self.viewController = viewController
    }
    
    func toggleSwitchView() {
        if let vc = self.viewController {
            if vc.viewType == .GRID {
                vc.viewType = .LIST
                self.cell.switchViewTypeButton.setImage(UIImage(named: "shoutsAsGrid"), forState: .Normal)
            } else if vc.viewType == .LIST {
                vc.viewType = .GRID
                self.cell.switchViewTypeButton.setImage(UIImage(named: "shoutsAsList"), forState: .Normal)
            }
        }
    }
    
}
