//
//  Assets.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func navBarLogoWhite() -> UIImage {
        return UIImage(named: "logo_navbar_white")!
    }
    
    static func backButton() -> UIImage {
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return UIImage(named: "rtl_backThin")!
        } else {
            return UIImage(named: "backThin")!
        }
    }
    
    static func menuHamburger() -> UIImage {
        return UIImage(named: "navMenu")!
    }
    
    static func suggestionAccessoryView() -> UIImage {
        return UIImage(named: "listen_icon")!
    }
    
    static func suggestionAccessoryViewSelected() -> UIImage {
        return UIImage(named: "listen_icon_green")!
    }
    
    static func downArrowDisclosureIndicator() -> UIImage {
        return UIImage(named: "down_thin")!
    }
    
    static func rightBlueArrowDisclosureIndicator() -> UIImage {
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            return UIImage(named: "rtl_forward_thin")!
        }
        return UIImage(named: "forward_thin")!
    }
    
    static func rightRedArrowDisclosureIndicator() -> UIImage {
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            return UIImage(named: "rtl_disclosure_indicator_red")!
        }
        return UIImage(named: "disclosure_indicator_red")!
    }
    
    static func rightGreenArrowDisclosureIndicator(forceLeftToRight forceLeftToRight: Bool = false) -> UIImage {
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft && forceLeftToRight == false {
            return UIImage(named: "rtl_disclosure_indicator_green")!
        }
        return UIImage(named: "disclosure_indicator_green")!
    }
    
    static func chatsSendButtonImage() -> UIImage {
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            return UIImage(named: "rtl_send")!
        }
        return UIImage(named: "send")!
    }
    
    // MARK - Search
    
    static func searchFillArrow() -> UIImage {
        return UIImage(named: "search_fill_arrow")!
    }
    
    static func searchRecentsIcon() -> UIImage {
        return UIImage(named: "search_recents_icon")!
    }
    
    static func searchUsersPlaceholder() -> UIImage {
        return UIImage(named: "search_users_placeholder")!
    }
    
    static func searchRecentRemoveIcon() -> UIImage {
        return UIImage(named: "search_recent_remove")!
    }
    
    static func shoutsLayoutListIcon() -> UIImage {
        return UIImage(named: "shoutsAsList")!
    }
    
    static func shoutsLayoutGridIcon() -> UIImage {
        return UIImage(named: "shoutsAsGrid")!
    }
    
    // MARK: - Filters
    
    static func filtersCheckbox() -> UIImage {
        return UIImage(named: "filter_checkbox")!
    }
    
    static func filtersCheckboxSelected() -> UIImage {
        return UIImage(named: "filter_checkbox_selected")!
    }
    
    // MARK: - Shout detail
    
    static func shoutDetailTabBarCallImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_call")!
    }
    
    static func shoutDetailTabBarVideoCallImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_videocall")!
    }
    
    static func shoutDetailTabBarChatImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_chat")!
    }
    
    static func shoutDetailTabBarMoreImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_tabmore")!
    }
    
    static func shoutDetailTabBarEditImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_edit")!
    }
    
    static func shoutDetailTabBarDeleteImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_delete")!
    }
    
    static func shoutDetailTabBarPromoteStarImage() -> UIImage {
        return UIImage(named: "shoutdetail_tab_promote_star")!
    }
    
    // MARK: - Profile
    
    static func profileBioIcon() -> UIImage {
        return UIImage(named: "profile_bio_icon")!
    }
    
    static func profileChatIcon() -> UIImage {
        return UIImage(named: "profile_chat_icon")!
    }
    
    static func profileCoverPlaceholder() -> UIImage {
        return UIImage(named: "profile_cover_placeholder")!
    }
    
    static func profileEditUserIcon() -> UIImage {
        return UIImage(named: "profile_edit_user_icon")!
    }
    
    static func profileDateJoinedIcon() -> UIImage {
        return UIImage(named: "profile_joined_icon")!
    }
    
    static func profileAboutIcon() -> UIImage {
        return UIImage(named: "profile_about_icon")!
    }
    
    static func profileListenIcon() -> UIImage {
        return UIImage(named: "listen_icon")!
    }
    
    static func profileStopListeningIcon() -> UIImage {
        return UIImage(named: "listen_icon_green")!
    }
    
    static func profileListenersIcon() -> UIImage {
        return UIImage(named: "profile_listeners_icon")!
    }
    
    static func profileListeningIcon() -> UIImage {
        return UIImage(named: "profile_listening_icon")!
    }
    
    static func profileMoreIcon() -> UIImage {
        return UIImage(named: "profile_more_icon")!
    }
    
    static func profileNotificationIcon() -> UIImage {
        return UIImage(named: "profile_notification_icon")!
    }
    
    static func profileTagsIcon() -> UIImage {
        return UIImage(named: "profile_tags_icon")!
    }
    
    static func profileWebsiteIcon() -> UIImage {
        return UIImage(named: "profile_website_icon")!
    }
    
    static func profileTagAvatar() -> UIImage {
        return UIImage(named: "default_tag")!
    }
    
    static func cameraIconWhite() -> UIImage {
        return UIImage(named: "photo_icon_small_white")!
    }
    
    static func cameraIconGray() -> UIImage {
        return UIImage(named: "photo_icon")!
    }
    
    static func tickIcon() -> UIImage {
        return UIImage(named: "tick")!
    }
    
    // MARK: - Placeholders
    
    static func squareAvatarPlaceholder() -> UIImage {
        return UIImage(named: "default_profile")!
    }
    
    static func squareAvatarPagePlaceholder() -> UIImage {
        return UIImage(named: "default_page")!
    }
    
    static func squareAvatarTagPlaceholder() -> UIImage {
        return UIImage(named: "default_tag")!
    }
    
    static func backgroundPattern() -> UIImage {
        return UIImage(named: "auth_screen_bg_pattern")!
    }
    
    static func shoutsPlaceholderImage() -> UIImage {
        return UIImage(named: "auth_screen_bg_pattern")!
    }
    
    static func profilePlaceholderImage() -> UIImage {
        return UIImage(named: "auth_screen_bg_pattern")!
    }
}
