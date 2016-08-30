//
//  Component.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Component {
    var active : Bool { get set }
    
    func loadContent() -> Void
    
    func refreshContent() -> Void
    
    
}

protocol ComponentStackViewRepresentable {
    func stackViewRepresentation() -> [UIView]
}