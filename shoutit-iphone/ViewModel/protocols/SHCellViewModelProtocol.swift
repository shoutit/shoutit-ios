//
//  SHCellViewModelProtocol.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 09/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

protocol SHCellViewModelProtocol {

    typealias T
    typealias I
    
    init(cell: T)
    
    func setup(item: I)
    
}
