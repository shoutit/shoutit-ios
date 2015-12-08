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
    private let USER_SHOUTS = SHApiManager.sharedInstance.BASE_URL + "/users"
    private let MESSAGES = SHApiManager.sharedInstance.BASE_URL + "/messages"
    
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
        let urlString = self.composeURLForShoutID(shoutId)
        var params = [String: AnyObject]()
        params = self.dictForAttachments([CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)])
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    func loadMessagesForConversation(conversationID: String, beforeTimeStamp: Int, cacheResponse: SHMessagesMeta -> Void, completionHandler: Response<SHMessagesMeta, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS + "/%@" + "/messages", arguments: [conversationID])
        var params = [String: AnyObject]()
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        if(beforeTimeStamp != 0) {
            params["before"] = beforeTimeStamp
        }
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func sendCoordinates(coordinates: CLLocationCoordinate2D, conversationID: String, localId: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS + "/%@" + "/reply", arguments: [conversationID])
        var params = [String: AnyObject]()
        params = self.dictForAttachments([CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)])
        if(!localId.isEmpty) {
            params["client_id"] = localId
        }
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    func deleteMessageID(messageID: String, completionHandler: Response<String, NSError> -> Void) {
        let urlString = String(format: MESSAGES + "/%@", arguments: [messageID])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.delete(urlString, params: params, completionHandler: completionHandler)
    }
    
    func sendShout(shout: SHShout, conversationId: String, localId: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS, arguments: [conversationId])
        var params = [String: AnyObject]()
        params = dictForAttachments([shout])
        if(!localId.isEmpty) {
            params["client_id"] = localId
        }
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    // Private
    private func composeURLForShoutID (shoutId: String) -> String {
        if(!shoutId.isEmpty) {
            return String(format: SHOUTS + "/%@" + "/reply", arguments: [shoutId])
        } else {
            if let username = SHOauthToken.getFromCache()?.user?.username {
                return String(format: USER_SHOUTS + "/%@" + "/message", arguments: [username])
            }
        }
        return ""
    }
    
    private func dictForAttachments(array: [AnyObject]) -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        var objArray = [AnyObject]()
        for obj in array {
            var objDict = [String: AnyObject]()
            if(obj.isKindOfClass(SHShout)) {
                objDict["shout"] = obj
                objArray.append(objDict)
            } else if(obj.isKindOfClass(CLLocation)) {
                if let loc = obj as? CLLocation {
                    var coordinatesDict = [String: AnyObject]()
                    coordinatesDict["longitude"] = loc.coordinate.longitude
                    coordinatesDict["latitude"] = loc.coordinate.latitude
                    objDict["location"] = coordinatesDict
                    objArray.append(objDict)
                }
            }
        }
        dict["attachments"] = objArray
        return dict
    }
}
