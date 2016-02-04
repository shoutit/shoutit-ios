//
//  Constants.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

struct Constants {
    struct Messages {
        static let SHImageMediaItem = "SHImageMediaItem"
        static let SHVideoMediaItem = "SHVideoMediaItem"
    }
    
    struct Shout {
        static let TIME_VIDEO_SHOUT = 60
        static let TIME_VIDEO_CV = 60
    }
    
    struct Common {
        static let SH_PAGE_SIZE = 60
    }
    
    struct Facebook {
        static let loginReadPermissions = ["public_profile", "email", "user_birthday"]
    }
    
    struct Google {
        static let clientID = "935842257865-lppn1neft859vr84flug604an2lh33dk.apps.googleusercontent.com"
        static let serverClientID = "935842257865-s6069gqjq4bvpi4rcbjtdtn2kggrvi06.apps.googleusercontent.com"
        static let GOOGLE_API_KEY = "AIzaSyBZsjPCMTtOFB79RsWn3oUGVPDImf4ceTU"
    }
    
    struct URL {
        static let ShoutItWebsite = "http://www.shoutit.com"
    }
    
    struct SharedUserDefaults {
        static let MIXPANEL = "MIXPANEL_USER_DEFAULTS"
        static let INIT_LOCATION = "initLocation"
        static let CUSTOM_LOCATION = "customLocation"
        static let SelectLocationAlert = "SelectLocationAlert"
    }
    
    struct ViewControllers {
        static let TAKE_LOGIN_VC = "SHTakeLoginViewController"
        static let DISCOVER_VC = "SHDiscoverFeedViewController"//"SHDiscoverCollectionViewController"
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
        static let SHPROFILE = "SHProfileCollectionViewController"
        static let SHSETTINGS = "SHSettingsTableViewController"
        static let SHMESSAGES = "SHMessagesViewController"
        static let SHSHOUTPICKERTABLE = "SHShoutPickerTableViewController"
        static let SHCONVERSATIONSTABLE = "SHConversationsTableViewController"
        static let SHEDITPROFILE = "SHEditProfileTableViewController"
        static let SHUSERLIST = "SHUserListTableViewController"
        static let SHMAPDETAIL = "SHMapDetatilViewController"
        static let SHTAGLISTENERS = "SHTagListenersTableViewController"
        static let ShoutList = "shoutListViewController"
        static let SHPostSignup = "SHPostSignupViewController"
        static let SHLOGINPOPUP =  "SHLoginPopupViewController"
        static let SHLOGIN = "SHLoginViewController"
        static let SHDISCOVERSHOUTS = "SHDiscoverShoutsViewController"
    }
    
    struct TableViewCell {
        static let SHLoginInputCell = "SHLoginInputCell"
        static let LocationSearchCell = "SearchCell"
        static let SHRequestVideoTableViewCell = "SHRequestVideoTableViewCell"
        static let SHRequestImageTableViewCell = "SHRequestImageTableViewCell"
        static let SHShoutTableViewCell = "SHShoutTableViewCell"
        static let SHTopTagTableViewCell = "SHTopTagTableViewCell"
        static let SHFilterCheckTableViewCell = "SHFilterCheckTableViewCell"
        static let SHStreamTagTableViewCell = "SHStreamTagTableViewCell"
        static let SHConversationTableViewCell = "SHConversationTableViewCell"
        static let SHShoutMessageCell = "SHShoutMessageCell"
        static let SHUserTableViewCell = "SHUserTableViewCell"
        static let SHPostSignupCategoriesCell = "SHPostSignupCategoriesCell"
    }
    
    struct CollectionViewCell {
        static let SHDiscoverCollectionViewCell = "SHDiscoverCollectionViewCell"
        static let SHCreatePlusCollectionViewCell = "SHCreatePlusCollectionViewCell"
        static let SHCreateImageCollectionViewCell = "SHCreateImageCollectionViewCell"
        static let SHCreateVideoCollectionViewCell = "SHCreateVideoCollectionViewCell"
        static let SHShoutDetailImageCollectionViewCell = "SHShoutDetailImageCollectionViewCell"
        static let SHYouTubeVideoCollectionViewCell = "SHYouTubeVideoCollectionViewCell"
        static let SHAmazonVideoCollectionViewCell = "SHAmazonVideoCollectionViewCell"
        static let SHShoutSquareCollectionViewCell = "SHShoutSquareCollectionViewCell"
        static let SHMessageShoutOutgoingCollectionViewCell = "SHMessageShoutOutgoingCollectionViewCell"
        static let ShoutMyFeedHeaderCell = "shoutMyFeedHeaderCell"
        static let ShoutDiscoverTitleCell = "shoutDiscoverTitleCell"
        static let ShoutDiscoverListCell = "shoutDiscoverListCell"
        static let ShoutDiscoverItemCell = "discoverItemCell"
        static let ShoutDiscoverSeeAllCell = "shDiscoverSeeAllCell"
        static let ShoutItemGridCell = "shShoutItemGridCell"
        static let ShoutItemListCell = "shShoutItemListCell"
        static let SHDiscoverFeedHeaderCell = "discoverFeedHeaderCell"
        static let SHDiscoverShoutHeaderCell = "discoverShoutHeaderCell"
        static let SHDiscoverShowMoreShoutsCell = "discoverShowMoreShoutsCell"
        static let SHDiscoverFeedCell = "SHDiscoverFeedCell"
        static let SHDiscoverShoutCell = "SHDiscoverShoutCell"
        static let SHDiscoverShoutsHeaderCell = "SHDiscoverShoutsHeaderCell"
        static let SHDiscoverShoutListCell = "SHDiscoverShoutListCell"
        static let SHExtraDiscoverCell = "SHExtraDiscoverCell"
    }
    
    struct CollectionReusableView {
        static let SHHeaderProfileReusableView = "SHHeaderProfileReusableView"
    }
    
    struct Authentication {
        static let clientID = "shoutit-ios"
        static let clientSecret = "209b7e713eca4774b5b2d8c20b779d91"
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
        static let ShoutStarted  = ".notification.ShoutStarted"
        static let kMessagePushNotification = "kMessagePushNotification"
        static let ToggleMenuNotification = "ToggleMenuNotification"
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
    
    struct AWS {
        static let SH_S3_USER_NAME = "shoutit-ios"
        static let SH_S3_ACCESS_KEY_ID = "AKIAJW62O3PBJT3W3HJA"
        static let SH_S3_SECRET_ACCESS_KEY = "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"
        static let SH_AMAZON_SHOUT_BUCKET = "shoutit-shout-image-original"
        static let SH_AMAZON_USER_BUCKET = "shoutit-user-image-original"
        
        static let SH_AMAZON_URL = "https://s3-eu-west-1.amazonaws.com/"
        static let SH_AWS_SHOUT_URL = "https://shout-image.static.shoutit.com/"
        static let SH_AWS_USER_URL = "https://user-image.static.shoutit.com/"
    }
    
    struct MessagesStatus {
        static let kStatusDelivered = NSLocalizedString("Delivered", comment: "Delivered")
        static let kStatusSent = NSLocalizedString("Sent", comment: "Sent")
        static let kStatusPending = NSLocalizedString("Pending", comment: "Pending")
        static let kStatusFailed = NSLocalizedString("Failed", comment: "Failed")
    }
}
