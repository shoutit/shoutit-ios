//
//  SHApiMessageService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiMessageService: NSObject {
    private let CONVERSATIONS = SHApiManager.sharedInstance.BASE_URL + "/conversations"
    
    func sendMessage(text: String, conversationID: String, localId: String, completionHandler: Response<SHMessage, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS + "/%@" + "/reply", arguments: [])
        var params = ["text": text]
//        if(localId) {
//            params[Constants.MessagesStatus]
//        }
        
    }
//        if (localId) {
//            [payload setValue:localId forKey:@"client_id"];
//        }    [SHRequestManager post:urlString params:nil payload:payload success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
//            {
//            SHMessage *msg =[mappingResult firstObject];
//            [self updateMessage:msg];
//            success(self, msg);
//            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            failure(self,error);
//            }];
        
        
    
}
