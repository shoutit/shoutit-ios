//
//  SHLocationGetterCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 10/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHLocationGetterCellViewModel: NSObject { //SHCellViewModelProtocol
    
    private let cell :SHLocationGetterViewCell
    
    required init(cell: SHLocationGetterViewCell) {
        self.cell = cell
    }

}
