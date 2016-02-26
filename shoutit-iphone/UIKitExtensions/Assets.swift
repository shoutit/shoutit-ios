//
//  Assets.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func navBarLogoImage() -> UIImage {
        return UIImage(named: "logo_navbar")!
    }
    
    static func backButton() -> UIImage {
        return UIImage(named: "backThin")!
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
    
    // MARK: - Placeholders
    
    static func squareAvatarPlaceholder() -> UIImage {
        return UIImage(named: "profile")!
    }
    
    static func backgroundPattern() -> UIImage {
        return UIImage(named: "auth_screen_bg_pattern")!
    }
}
