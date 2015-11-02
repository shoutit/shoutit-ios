//
//  ViewModelProtocol.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

protocol ViewControllerModelProtocol {
    
    typealias T
    
    init(viewController: T)
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
    func destroy()
    
}