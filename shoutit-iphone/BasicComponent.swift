//
//  BasicComponent.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class BasicComponent : NSObject, Component {
    var isLoaded : Bool = false
    var isLoading : Bool = false
    
    var active : Bool = false {
        didSet {
            if active && !isLoaded && !isLoading {
                self.loadContent()
            }
        }
    }
    
    func loadContent() {
        
    }
    
    func refreshContent() {
        
    }
}