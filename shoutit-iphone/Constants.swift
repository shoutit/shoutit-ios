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
        static let clientID = "759293649336-bist95s97m2f84o8clnvv0upuh4vfmmp.apps.googleusercontent.com"
    }
    
    struct RegEx {
        static let REGEX_EMAIL = "[A-Z0-9a-z._%+-]{1,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}"
        static let REGEX_PASSWORD_LIMIT = "^.{6,20}$"
        
    }
    
    struct SharedUserDefaults {
        static let MIXPANEL = "MIXPANEL_USER_DEFAULTS"
        static let INIT_LOCATION = "initLocation"
    }
    
    struct StoryboardIdentifier {
        
    }
    
    struct Style {
        static let COLOR_BACKGROUND_WHITE = "#fafafa"
        static let COLOR_BACKGROUND_GRAY = "#333333"
        static let COLOR_SHOUT_GREEN = "#98dc1a"
        static let COLOR_SHOUT_RED = "#ca3c3c"
        static let COLOR_SHOUT_DARK_GREEN = "#658529"
        static let COLOR_MESSAGE_BUBBLE_LIGT_GREEN = "#91f261"
    }
    
    struct ViewControllers {
        static let DISCOVER_VC = UIStoryboard.getDiscover().instantiateViewControllerWithIdentifier("SHDiscoverCollectionViewController")
    }
    
    struct TableViewCell {
        static let SHLoginInputCell = "SHLoginInputCell"
        static let SHDiscoverCollectionViewCell = "SHDiscoverCollectionViewCell"
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
        static let SHAddress  = ".sh.cache.shAddress"
    }
}
