//
//  CompoundDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class CompoundDataSource : BasicDataSource {

    private var subSources : [BasicDataSource]!
    
    override var active : Bool {
        didSet {
            if active == false { return }
            
            for source in subSources {
                source.active = active
            }
            
            if self.stateMachine.currentState == .Initial || shouldReloadOnActive {
                loadContent()
            }
        }
    }
    
    init(subSources: [BasicDataSource]) {
        super.init()
        
        self.subSources = subSources
    }
    
    override func loadContent() {
        
    }
}