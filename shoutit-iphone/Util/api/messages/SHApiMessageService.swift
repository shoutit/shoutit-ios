//
//  SHApiMessageService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

class SHApiMessageService: NSObject {
    private let CONVERSATIONS = SHApiManager.sharedInstance.BASE_URL + "/conversations"
    private let SHOUTS = SHApiManager.sharedInstance.BASE_URL + "/shouts"
    
    func sendMessage(text: String, conversationID: String, localId: String, completionHandler: Response<SHMessage, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS + "/%@" + "/reply", arguments: [])
        var params = [String: AnyObject]()
        params["text"] = text
        if(localId != "") {
            params["client_id"] = localId
        }
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    func composeShout(shout: SHShout, shoutId: String, completionHandler: Response<SHMessage, NSError> -> Void) {
        let urlString = String(format: SHOUTS + "/%@" + "/reply", arguments: [shoutId])
        var params = [String: AnyObject]()
        params["shout"] = shout
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    func composeCoordinates(coordinates: CLLocationCoordinate2D, shoutId: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        
    }
}
