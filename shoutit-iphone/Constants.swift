//
//  Constants.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Shout {
        static let TIME_VIDEO_SHOUT = 60
        static let TIME_VIDEO_CV = 60
    }
    
    struct Common {
        static let SH_PAGE_SIZE = 60
    }
    
    struct Google {
        static let clientID = "935842257865-lppn1neft859vr84flug604an2lh33dk.apps.googleusercontent.com"
        static let serverClientID = "935842257865-s6069gqjq4bvpi4rcbjtdtn2kggrvi06.apps.googleusercontent.com"
        static let GOOGLE_API_KEY = "AIzaSyBZsjPCMTtOFB79RsWn3oUGVPDImf4ceTU"
    }
    
    struct RegEx {
        static let REGEX_EMAIL = "[A-Z0-9a-z._%+-]{1,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}"
        static let REGEX_PASSWORD_LIMIT = "^.{6,20}$"
        
    }
    
    struct SharedUserDefaults {
        static let MIXPANEL = "MIXPANEL_USER_DEFAULTS"
        static let INIT_LOCATION = "initLocation"
        static let CUSTOM_LOCATION = "customLocation"
        static let SelectLocationAlert = "SelectLocationAlert"
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
        static let COLOR_SHOUTDETAIL_PROFILEIMAGE = "#e8e8e8"
    }
    
    struct ViewControllers {
        static let DISCOVER_VC = "SHDiscoverCollectionViewController"
        static let STREAM_VC = "SHStreamTableViewController"
        static let MODEL_WEB = "SHModalWebViewController"
        static let LOCATION_GETTER = "SHLocationGetterViewController"
        static let CREATE_SHOUT = "shCreateShoutTableViewController"
        static let PHOTO_PREVIEW = "SHPhotoPreviewViewController"
        static let VIDEO_PREVIEW = "SHVideoPreviewViewController"
        static let STREAM_MAP = "SHStreamMapViewController"
        static let SHFILTER = "SHFilterViewController"
        static let SHTAGPROFILE = "SHTagProfileTableViewController"
        static let SHFILTERPRICE = "SHFilterPriceTableViewController"
        static let SHFILTERCHECKMARK = "SHFilterCheckmarkTableViewController"
        static let SHCATEGORYTAGS = "SHCategoryTagsViewController"
        static let SHSHOUTDETAIL = "SHShoutDetailTableViewController"
    }
    
    struct TableViewCell {
        static let SHLoginInputCell = "SHLoginInputCell"
        static let LocationSearchCell = "SearchCell"
        static let SHRequestVideoTableViewCell = "SHRequestVideoTableViewCell"
        static let SHRequestImageTableViewCell = "SHRequestImageTableViewCell"
        static let SHShoutTableViewCell = "SHShoutTableViewCell"
        static let SHTopTagTableViewCell = "SHTopTagTableViewCell"
        static let SHFilterCheckTableViewCell = "SHFilterCheckTableViewCell"
    }
    
    struct CollectionViewCell {
        static let SHDiscoverCollectionViewCell = "SHDiscoverCollectionViewCell"
        static let SHCreatePlusCollectionViewCell = "SHCreatePlusCollectionViewCell"
        static let SHCreateImageCollectionViewCell = "SHCreateImageCollectionViewCell"
        static let SHCreateVideoCollectionViewCell = "SHCreateVideoCollectionViewCell"
        static let SHShoutDetailImageCollectionViewCell = "SHShoutDetailImageCollectionViewCell"
        static let SHYouTubeVideoCollectionViewCell = "SHYouTubeVideoCollectionViewCell"
        static let SHAmazonVideoCollectionViewCell = "SHAmazonVideoCollectionViewCell"
    }
    
    struct Authentication {
        static let SH_CLIENT_ID = "shoutit-ios"
        static let SH_CLIENT_SECRET = "209b7e713eca4774b5b2d8c20b779d91"
    }
    
    struct MixPanel {
        static let MIXPANEL_TOKEN  = "c9d0a1dc521ac1962840e565fa971574"
    }
    
    struct Cache {
        static let OauthToken = ".sh.cache.oauthToken"
        static let SHAddress = ".sh.cache.shAddress"
        static let Categories = ".sh.cache.categories"
        static let Currencies = ".sh.cache.currencies"
    }
    
    struct Notification {
        static let LocationUpdated  = ".notification.LocationUpdated"
    }
    
    struct Filter {
        static let kLeftLable = "kLeftLablel"
        static let kRightLable = "kRightLablel"
        static let kCellType = "kCellType"
        static let KTagsArray = "KTagsArray"
        
        
        static let kStandardCellId = "kStandardCellId"
        static let kTextFieldCellId = "kTextFieldCellId"
        static let kCenterCellId = "kCenterCellId"
        static let kTagsCellId = "SHFilterTagsTableViewCell"
        
        static let kIsApply = "kIsApply"
        static let kSelectorName = "kSelectorName"
    }
}
