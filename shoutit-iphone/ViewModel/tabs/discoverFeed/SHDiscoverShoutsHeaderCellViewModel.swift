//
//  SHDiscoverShoutsHeaderCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutsHeaderCellViewModel: NSObject {
    
    private let cell: SHDiscoverShoutsHeaderCell
    private var viewController: SHDiscoverShoutsViewController?
    
    init(cell: SHDiscoverShoutsHeaderCell) {
        self.cell = cell
    }
    
    func setUp(viewController: SHDiscoverShoutsViewController?) {
        self.viewController = viewController
    }

    func toggleSwitchView() {
        if let vc = self.viewController {
            if vc.viewType == .GRID {
                vc.viewType = .LIST
                self.cell.shoutViewType.setImage(UIImage(named: "shoutsAsGrid"), forState: .Normal)
            } else if vc.viewType == .LIST {
                vc.viewType = .GRID
                self.cell.shoutViewType.setImage(UIImage(named: "shoutsAsList"), forState: .Normal)
            }
        }
    }
}
