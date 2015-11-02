//
//  NetworkActivityManager.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class NetworkActivityManager: NSObject {

    static var activitiesCount = 0
    
    static func addActivity() {
        if activitiesCount == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        
        activitiesCount++
    }
    
    static func removeActivity() {
        if activitiesCount > 0 {
            activitiesCount--
            
            if activitiesCount == 0 {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
}
