//
//  BasicDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

//
//class BasicDataSource : NSObject, LoadableDataSource {
//    
//    
//    var shouldReloadOnActive = false
//    
//    var active : Bool {
//        didSet {
//            if active == false { return }
//            
//            if self.stateMachine.currentState == .Initial || shouldReloadOnActive {
//                loadContent()
//            }
//        }
//    }
//    
//    func loadContent() {
//        assertionFailure("Override this method")
//    }
//    
//    override init() {
//        self.active = false
//        
//        super.init()
//    }
//    
//}