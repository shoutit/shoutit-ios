//
//  Wireframe.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

struct Wireframe {
    
    enum Storyboard: String {
        case Root = "Root"
        case Login = "LoginStoryboard"
        case HTML = "HTML"
        case Home = "Home"
        case Discover = "Discover"
        case Shout = "Shout"
        case ShoutDetail = "ShoutDetail"
        case Chats = "Chats"
        case Profile = "Profile"
        case Settings = "Settings"
        case Location = "Location"
        case InviteFriends = "InviteFriends"
        case EditProfile = "EditProfile"
        case Notifications = "Notifications"
        case Search = "Search"
        case VerifyEmail = "VerifyEmail"
        case VideoCalls = "VideoCalls"
        case Filter = "Filter"
        case SeeAllShouts = "SeeAllShouts"
    }
    
    // General
    
    static func storyboard(storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
    }
    
    // MARK: - Root storyboard view controller
    
    static func mainInterfaceViewController() -> RootController {
        return storyboard(.Root).instantiateViewControllerWithIdentifier("RootController") as! RootController
    }
    
    // MARK: - Login storyboard view controllers
    
    static func introViewController() -> IntroViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
    }
    
    static func loginMethodChoiceViewController() -> LoginMethodChoiceViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginMethodChoiceViewController") as! LoginMethodChoiceViewController
    }
    
    static func loginWithEmailViewController() -> LoginWithEmailViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginWithEmailViewController") as! LoginWithEmailViewController
    }
    
    static func signupViewController() -> SignupViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
    }
    
    static func loginViewController() -> LoginViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }
    
    static func resetPasswordViewController() -> ResetPasswordViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("ResetPasswordViewController") as! ResetPasswordViewController
    }
    
    static func postSignupInterestsViewController() -> PostSignupInterestsViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("PostSignupInterestsViewController") as! PostSignupInterestsViewController
    }
    
    static func postSignupSuggestionsViewController() -> PostSignupSuggestionsWrappingViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("PostSignupSuggestionsWrappingViewController") as! PostSignupSuggestionsWrappingViewController
    }
    
    static func postSignupSuggestionsTableViewController() -> PostSignupSuggestionsTableViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("PostSignupSuggestionsTableViewController") as! PostSignupSuggestionsTableViewController
    }
    
    static func introContentViewControllerForPage(page: Int) -> UIViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("IntroContent\(page)")
    }
    
    // MARK: - Search storyboard view controllers
    
    static func searchViewController() -> SearchViewController {
        return storyboard(.Search).instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
    }
    
    static func searchUserResultsTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Search).instantiateViewControllerWithIdentifier("SearchUserResultsTableViewController") as! ProfilesListTableViewController
    }
    
    static func searchShoutsResultsCollectionViewController() -> SearchShoutsResultsCollectionViewController {
        return storyboard(.Search).instantiateViewControllerWithIdentifier("SearchShoutsResultsCollectionViewController") as! SearchShoutsResultsCollectionViewController
    }
    
    // MARK: - Filters storyboard view controllers
    
    static func filtersViewController() -> FiltersViewController {
        return storyboard(.Filter).instantiateViewControllerWithIdentifier("FiltersViewController") as! FiltersViewController
    }
    
    static func filtersChangeLocationViewController() -> FilterLocationChoiceWrapperViewController {
        return storyboard(.Filter).instantiateViewControllerWithIdentifier("FilterLocationChoiceWrapperViewController") as! FilterLocationChoiceWrapperViewController
    }
    
    static func categoryFiltersChoiceViewController() -> CategoryFiltersViewController {
        return storyboard(.Filter).instantiateViewControllerWithIdentifier("CategoryFiltersViewController") as! CategoryFiltersViewController
    }
    
    // MARK: - HTML storyboard view controllers
    
    static func htmlViewController() -> HTMLViewController {
        return storyboard(.HTML).instantiateInitialViewController() as! HTMLViewController
    }
    
    // MARK: - ShoutDetail storyboard view controllers
    
    static func shoutDetailContainerViewController() -> ShowDetailContainerViewController {
        return storyboard(.ShoutDetail).instantiateViewControllerWithIdentifier("ShowDetailContainerViewController") as! ShowDetailContainerViewController
    }
    
    static func shoutDetailTableViewController() -> ShoutDetailTableViewController {
        return storyboard(.ShoutDetail).instantiateViewControllerWithIdentifier("ShoutDetailTableViewController") as! ShoutDetailTableViewController
    }
    
    static func photoBrowserPhotoViewController() -> PhotoBrowserPhotoViewController {
        return storyboard(.ShoutDetail).instantiateViewControllerWithIdentifier("PhotoBrowserPhotoViewController") as! PhotoBrowserPhotoViewController
    }
    
    // MARK: - Seel all shous storyboard view controllers
    
    static func allShoutsCollectionViewController() -> ShoutsCollectionViewController {
        return storyboard(.SeeAllShouts).instantiateViewControllerWithIdentifier("ShoutsCollectionViewController") as! ShoutsCollectionViewController
    }
    
    // MARK: - Edit profile storyboard controllers
    
    static func editProfileTableViewController() -> EditProfileTableViewController {
        return storyboard(.EditProfile).instantiateViewControllerWithIdentifier("EditProfileTableViewController") as! EditProfileTableViewController
    }
    
    // MARK: - Verify email storyboard controllers
    
    static func verifyEmailViewController() -> VerifyEmailViewController {
        return storyboard(.VerifyEmail).instantiateViewControllerWithIdentifier("VerifyEmailViewController") as! VerifyEmailViewController
    }
    
    // MARK: - Home storyboard view controllers

    static func homeViewController() -> HomeViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("homeRootController") as! HomeViewController
    }
    
    static func ordersViewController() -> UIViewController {
        return UIViewController()
    }
    
    static func discoverViewController() -> DiscoverCollectionViewController {
        return storyboard(.Discover).instantiateViewControllerWithIdentifier("SHDiscoverCollectionViewController") as! DiscoverCollectionViewController
    }
    
    static func shoutViewController() -> CreateShoutPopupViewController {
        return storyboard(.Shout).instantiateViewControllerWithIdentifier("shCreateShoutTableViewController") as! CreateShoutPopupViewController
    }
    
    static func settingsViewController() -> SettingsTableViewController {
        return storyboard(.Settings).instantiateViewControllerWithIdentifier("SettingsTableViewController") as! SettingsTableViewController
    }
    
    static func settingsFromViewController() -> SettingsFormViewController {
        return storyboard(.Settings).instantiateViewControllerWithIdentifier("SettingsFormViewController") as! SettingsFormViewController
    }
    
    static func inviteFriendsViewController() -> InviteFriendsTableViewController {
        return storyboard(.InviteFriends).instantiateViewControllerWithIdentifier("InviteFriendsRootController") as! InviteFriendsTableViewController
    }
    
    static func locationViewController() -> ChangeLocationTableViewController {
        return storyboard(.Location).instantiateViewControllerWithIdentifier("LocationRootController") as! ChangeLocationTableViewController
    }
    
    static func chatsViewController() -> ConversationListsParentViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationListsParentViewController") as! ConversationListsParentViewController
    }
    
    static func groupChatsViewController() -> ConversationGroupWrapperViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationGroupWrapperViewController") as! ConversationGroupWrapperViewController
    }
    
    static func chatsListTableViewController() -> ConversationListTableViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("SHConversationsTableViewController") as! ConversationListTableViewController
    }
    
    static func createPublicChatViewController() -> CreatePublicChatWrappingViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("CreatePublicChatWrappingViewController") as! CreatePublicChatWrappingViewController
    }
    
    static func profileViewController() -> ProfileCollectionViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("ProfileCollectionViewController") as! ProfileCollectionViewController
    }
    
    static func listenersListTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("ListenersListViewController") as! ProfilesListTableViewController
    }
    
    static func listeningListTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("ListeningListViewController") as! ProfilesListTableViewController
    }
    
    static func interestsListTableViewController() -> TagsListTableViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("InterestsListViewController") as! TagsListTableViewController
    }
    
    static func changeShoutLocationController() -> SelectShoutLocationViewController {
        return storyboard(.Location).instantiateViewControllerWithIdentifier("ShoutLocationController") as! SelectShoutLocationViewController
    }
    
    static func shoutConfirmationController() -> ShoutConfirmationViewController {
        return storyboard(.Shout).instantiateViewControllerWithIdentifier("shoutConfirmation") as! ShoutConfirmationViewController
    }
    
    static func editShoutController() -> EditShoutParentViewController {
        return storyboard(.Shout).instantiateViewControllerWithIdentifier("editShoutTableViewController") as! EditShoutParentViewController
    }
    
    static func suggestionsController() -> PostSignupSuggestionsTableViewController {
        return storyboard(.InviteFriends).instantiateViewControllerWithIdentifier("SuggestionsTableViewController") as! PostSignupSuggestionsTableViewController
    }
    
    static func createShoutWithTypeController(type: ShoutType) -> CreateShoutParentViewController {
        let controller =  storyboard(.Shout).instantiateViewControllerWithIdentifier("createShoutParentController") as! CreateShoutParentViewController

        controller.type = type
        
        return controller
    }
    
    static func selectShoutAttachmentController() -> ConversationSelectShoutController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationSelectShoutController") as! ConversationSelectShoutController
    }
    
    static func conversationSelectProfileAttachmentParentController() -> ConversationSelectProfileAttachmentViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationSelectProfileAttachmentViewController") as! ConversationSelectProfileAttachmentViewController
    }
    
    static func conversationSelectProfileAttachmentController() -> ProfilesListTableViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ProfilesListTableViewController") as! ProfilesListTableViewController
    }
    
    static func notificationsController() -> NotificationsTableViewController {
        return storyboard(.Notifications).instantiateInitialViewController() as! NotificationsTableViewController
    }
    
    static func conversationController() -> ConversationViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("conversationController") as! ConversationViewController
    }
    
    static func conversationInfoController() -> ConversationInfoViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("conversationInfoController") as! ConversationInfoViewController
    }
    
    static func conversationAttachmentController() -> ConversationAttachmentViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationAttachmentViewController") as! ConversationAttachmentViewController
    }
    
    static func conversationLocationController() -> ConversationLocationController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("ConversationLocationController") as! ConversationLocationController
    }
    
    static func callingoutController() -> CallingOutViewController {
        return storyboard(.VideoCalls).instantiateViewControllerWithIdentifier("CallingOutViewController") as! CallingOutViewController
    }
    
    static func videoCallController() -> VideoCallViewController {
        return storyboard(.VideoCalls).instantiateViewControllerWithIdentifier("VideoCallViewController") as! VideoCallViewController
    }
    
    static func incomingCallController() -> IncomingCallController {
        return storyboard(.VideoCalls).instantiateViewControllerWithIdentifier("IncomingCallController") as! IncomingCallController
    }
    
}
