//
//  Constants.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Google {
        static let clientID = "759293649336-v9benmmh0r4si673gk3305u6lgvmpeb5.apps.googleusercontent.com"
    }
    
    struct RegEx {
        static let REGEX_EMAIL = "[A-Z0-9a-z._%+-]{1,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}"
        static let REGEX_PASSWORD_LIMIT = "^.{6,20}$"
        
    }
    
    struct SharedUserDefaults {
        static let MIXPANEL = ".User.Defaults.Mixpanel"
        static let INIT_LOCATION = ".User.Init.Location"
    }
    
    struct StoryboardIdentifier {
        
    }
    
    struct ViewControllers {
        
    }
    
    struct Authentication {
        static let SH_CLIENT_ID = "shoutit-ios"
        static let SH_CLIENT_SECRET = "209b7e713eca4774b5b2d8c20b779d91"
    }
    
    struct MixPanel {
        static let MIXPANEL_TOKEN  = "c9d0a1dc521ac1962840e565fa971574"
    }
    
    struct Cache {
        static let OauthToken  = ".sh.cache.oauthToken"
    }
}
