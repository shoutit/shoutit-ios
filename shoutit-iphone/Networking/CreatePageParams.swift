//
//  CreatePageParams.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

public struct PageSignupParams: AuthParams {
    
    public let grantType = "shoutit_page"
    public let category : PageCategory
    public let name : String
    public let userFullName : String
    public let email : String
    public let password : String
    
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public var authParams: [String : AnyObject] {
        return [
            "page_category": try! category.toJSON() as AnyObject,
            "page_name" : name as AnyObject,
            "email" : email as AnyObject,
            "name": userFullName as AnyObject,
            "password": password as AnyObject
        ]
    }
    
    public init(category: PageCategory, name: String, email: String, userFullName: String, password: String, mixPanelDistinctId: String, currentUserCoordinates: CLLocationCoordinate2D) {
        self.category = category
        self.name = name
        self.email = email
        self.password = password
        self.userFullName = userFullName
        self.mixPanelDistinctId = mixPanelDistinctId
        self.currentUserCoordinates = currentUserCoordinates
    }
}

public struct PageCreationParams : Params {
    public let category : PageCategory
    public let name : String
 
    public var params: [String : AnyObject] {
        return [
            "page_category": try! category.toJSON() as AnyObject,
            "page_name": name as AnyObject
        ]
    }
}
