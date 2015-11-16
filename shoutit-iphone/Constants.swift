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
        static let STREAM_VC =
        UIStoryboard.getStream().instantiateViewControllerWithIdentifier("SHStreamTableViewController")
        static let MODEL_WEB = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier("SHModalWebViewController")
        static let LOCATION_GETTER = UIStoryboard.getStream().instantiateViewControllerWithIdentifier("SHLocationGetterViewController")
        static let CREATE_SHOUT = UIStoryboard.getCreateShout().instantiateViewControllerWithIdentifier("shCreateShoutTableViewController")
        static let CAMERA_VC = SHCameraViewController(nibName: "CameraView", bundle: NSBundle.mainBundle())
        static let PHOTO_PREVIEW = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier("SHPhotoPreviewViewController")
        static let VIDEO_PREVIEW = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier("SHVideoPreviewViewController")
        static let STREAM_MAP =
        UIStoryboard.getStream().instantiateViewControllerWithIdentifier("SHStreamMapViewController")
        static let SHFILTER =
        UIStoryboard.getFilter().instantiateViewControllerWithIdentifier("SHFilterViewController")
    }
    
    struct TableViewCell {
        static let SHLoginInputCell = "SHLoginInputCell"
        static let LocationSearchCell = "SearchCell"
        static let SHRequestVideoTableViewCell = "SHRequestVideoTableViewCell"
        static let SHRequestImageTableViewCell = "SHRequestImageTableViewCell"
        static let SHShoutTableViewCell = "SHShoutTableViewCell"
    }
    
    struct CollectionViewCell {
        static let SHDiscoverCollectionViewCell = "SHDiscoverCollectionViewCell"
        static let SHCreatePlusCollectionViewCell = "SHCreatePlusCollectionViewCell"
        static let SHCreateImageCollectionViewCell = "SHCreateImageCollectionViewCell"
        static let SHCreateVideoCollectionViewCell = "SHCreateVideoCollectionViewCell"
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
    
    struct Notification {
        static let LocationUpdated  = ".notification.LocationUpdated"
    }
    
    struct Filter {
        static let kLeftLablel = "kLeftLablel"
        static let kRightLablel = "kRightLablel"
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
