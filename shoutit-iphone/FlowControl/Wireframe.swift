//
//  Wireframe.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

struct Wireframe {
    
    enum Storyboard: String {
        case Root = "Root"
        case Login = "LoginStoryboard"
        case HTML = "HTML"
        case Home = "Home"
        case Discover = "Discover"
        case Bookmarks = "Bookmarks"
        case Credits = "Credits"
        case Shout = "Shout"
        case ShoutDetail = "ShoutDetail"
        case Chats = "Chats"
        case Profile = "Profile"
        case Settings = "Settings"
        case Location = "Location"
        case InviteFriends = "InviteFriends"
        case EditProfile = "EditProfile"
        case EditPage = "EditPage"
        case Notifications = "Notifications"
        case Search = "Search"
        case VerifyEmail = "VerifyEmail"
        case VideoCalls = "VideoCalls"
        case Filter = "Filter"
        case SeeAllShouts = "SeeAllShouts"
        case Promote = "Promote"
        case Pages = "Pages"
        case Admins = "Admins"
        case StaticPage = "StaticPage"
    }
    
    // General
    
    static func storyboard(_ storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
    }
    
    // MARK: - Root storyboard view controller
    
    static func mainInterfaceViewController() -> RootController {
        return storyboard(.Root).instantiateViewController(withIdentifier: "RootController") as! RootController
    }
    
    // MARK: - Login storyboard view controllers
    
    static func introViewController() -> IntroViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
    }
    
    static func loginMethodChoiceViewController() -> LoginMethodChoiceViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "LoginMethodChoiceViewController") as! LoginMethodChoiceViewController
    }
    
    static func loginWithEmailViewController() -> LoginWithEmailViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "LoginWithEmailViewController") as! LoginWithEmailViewController
    }
    
    static func signupViewController() -> SignupViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
    }
    
    static func loginViewController() -> LoginViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    static func resetPasswordViewController() -> ResetPasswordViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
    }
    
    static func postSignupInterestsViewController() -> PostSignupInterestsViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "PostSignupInterestsViewController") as! PostSignupInterestsViewController
    }
    
    static func postSignupSuggestionsViewController() -> PostSignupSuggestionsWrappingViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "PostSignupSuggestionsWrappingViewController") as! PostSignupSuggestionsWrappingViewController
    }
    
    static func postSignupSuggestionsTableViewController() -> PostSignupSuggestionsTableViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "PostSignupSuggestionsTableViewController") as! PostSignupSuggestionsTableViewController
    }
    
    static func introContentViewControllerForPage(_ page: Int) -> UIViewController {
        return storyboard(.Login).instantiateViewController(withIdentifier: "IntroContent\(page)")
    }
    
    // MARK: - Search storyboard view controllers
    
    static func searchViewController() -> SearchViewController {
        return storyboard(.Search).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
    }
    
    static func searchUserResultsTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Search).instantiateViewController(withIdentifier: "SearchUserResultsTableViewController") as! ProfilesListTableViewController
    }
    
    static func searchShoutsResultsCollectionViewController() -> SearchShoutsResultsCollectionViewController {
        return storyboard(.Search).instantiateViewController(withIdentifier: "SearchShoutsResultsCollectionViewController") as! SearchShoutsResultsCollectionViewController
    }
    
    // MARK: - Filters storyboard view controllers
    
    static func filtersViewController() -> FiltersViewController {
        return storyboard(.Filter).instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
    }
    
    static func filtersChangeLocationViewController() -> FilterLocationChoiceWrapperViewController {
        return storyboard(.Filter).instantiateViewController(withIdentifier: "FilterLocationChoiceWrapperViewController") as! FilterLocationChoiceWrapperViewController
    }
    
    static func categoryFiltersChoiceViewController() -> CategoryFiltersViewController {
        return storyboard(.Filter).instantiateViewController(withIdentifier: "CategoryFiltersViewController") as! CategoryFiltersViewController
    }
    
    // MARK: - HTML storyboard view controllers
    
    static func htmlViewController() -> HTMLViewController {
        return storyboard(.HTML).instantiateInitialViewController() as! HTMLViewController
    }
    
    // MARK: - ShoutDetail storyboard view controllers
    
    static func shoutDetailContainerViewController() -> ShowDetailContainerViewController {
        return storyboard(.ShoutDetail).instantiateViewController(withIdentifier: "ShowDetailContainerViewController") as! ShowDetailContainerViewController
    }
    
    static func shoutDetailTableViewController() -> ShoutDetailTableViewController {
        return storyboard(.ShoutDetail).instantiateViewController(withIdentifier: "ShoutDetailTableViewController") as! ShoutDetailTableViewController
    }
    
    static func photoBrowserPhotoViewController() -> PhotoBrowserPhotoViewController {
        return storyboard(.ShoutDetail).instantiateViewController(withIdentifier: "PhotoBrowserPhotoViewController") as! PhotoBrowserPhotoViewController
    }
    
    // MARK: - Seel all shous storyboard view controllers
    
    static func allShoutsCollectionViewController() -> ShoutsCollectionViewController {
        return storyboard(.SeeAllShouts).instantiateViewController(withIdentifier: "ShoutsCollectionViewController") as! ShoutsCollectionViewController
    }
    
    // MARK: - Edit profile storyboard controllers
    
    static func editProfileTableViewController() -> EditProfileTableViewController {
        return storyboard(.EditProfile).instantiateViewController(withIdentifier: "EditProfileTableViewController") as! EditProfileTableViewController
    }
    
    // MARK: - Edit page storyboard controllers
    
    static func editPageTableViewController() -> EditPageTableViewController {
        return storyboard(.EditPage).instantiateViewController(withIdentifier: "EditPageTableViewController") as! EditPageTableViewController
    }
    
    // MARK: - Verify email storyboard controllers
    
    static func verifyEmailViewController() -> VerifyEmailViewController {
        return storyboard(.VerifyEmail).instantiateViewController(withIdentifier: "VerifyEmailViewController") as! VerifyEmailViewController
    }
    
    static func verifyPageViewController() -> VerifyPageViewController {
        return storyboard(.VerifyEmail).instantiateViewController(withIdentifier: "VerifyPageViewController") as! VerifyPageViewController
    }
    
    
    // MARK: - Home storyboard view controllers

    static func homeViewController() -> HomeViewController {
        return storyboard(.Home).instantiateViewController(withIdentifier: "homeRootController") as! HomeViewController
    }
    
    static func ordersViewController() -> UIViewController {
        return UIViewController()
    }
    
    static func creditsViewController() -> CreditsMainViewController {
        return storyboard(.Credits).instantiateViewController(withIdentifier: "CreditsMainViewController") as! CreditsMainViewController
    }
    
    static func creditTransactionsViewController() -> CreditTransactionsTableViewController {
        return storyboard(.Credits).instantiateViewController(withIdentifier: "CreditTransactionsTableViewController") as! CreditTransactionsTableViewController
    }
    
    static func creditPromotingShoutsInfoViewController() -> PromotingShoutsInfoController {
        return storyboard(.Credits).instantiateViewController(withIdentifier: "PromotingShoutsInfoController") as! PromotingShoutsInfoController
    }
    
    static func bookmarksViewController() -> BookmarksCollectionViewController {
        return storyboard(.Bookmarks).instantiateViewController(withIdentifier: "BookmarksCollectionViewController") as! BookmarksCollectionViewController
    }
    
    static func discoverViewController() -> DiscoverCollectionViewController {
        return storyboard(.Discover).instantiateViewController(withIdentifier: "SHDiscoverCollectionViewController") as! DiscoverCollectionViewController
    }
    
    static func shoutViewController() -> CreateShoutPopupViewController {
        return storyboard(.Shout).instantiateViewController(withIdentifier: "shCreateShoutTableViewController") as! CreateShoutPopupViewController
    }
    
    static func settingsViewController() -> SettingsTableViewController {
        return storyboard(.Settings).instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
    }
    
    static func settingsFromViewController() -> SettingsFormViewController {
        return storyboard(.Settings).instantiateViewController(withIdentifier: "SettingsFormViewController") as! SettingsFormViewController
    }
    
    static func inviteFriendsViewController() -> InviteFriendsTableViewController {
        return storyboard(.InviteFriends).instantiateViewController(withIdentifier: "InviteFriendsRootController") as! InviteFriendsTableViewController
    }
    
    static func locationViewController() -> ChangeLocationTableViewController {
        return storyboard(.Location).instantiateViewController(withIdentifier: "LocationRootController") as! ChangeLocationTableViewController
    }
    
    static func chatsViewController() -> ConversationListsParentViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationListsParentViewController") as! ConversationListsParentViewController
    }
    
    static func groupChatsViewController() -> ConversationGroupWrapperViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationGroupWrapperViewController") as! ConversationGroupWrapperViewController
    }
    
    static func chatsListTableViewController() -> ConversationListTableViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "SHConversationsTableViewController") as! ConversationListTableViewController
    }
    
    static func createPublicChatViewController() -> CreatePublicChatWrappingViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "CreatePublicChatWrappingViewController") as! CreatePublicChatWrappingViewController
    }
    
    static func profileViewController() -> ProfileCollectionViewController {
        return storyboard(.Profile).instantiateViewController(withIdentifier: "ProfileCollectionViewController") as! ProfileCollectionViewController
    }
    
    static func listenersListTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Profile).instantiateViewController(withIdentifier: "ListenersListViewController") as! ProfilesListTableViewController
    }
    
    static func listeningListTableViewController() -> ProfilesListTableViewController {
        return storyboard(.Profile).instantiateViewController(withIdentifier: "ListeningListViewController") as! ProfilesListTableViewController
    }
    
    static func interestsListTableViewController() -> TagsListTableViewController {
        return storyboard(.Profile).instantiateViewController(withIdentifier: "InterestsListViewController") as! TagsListTableViewController
    }
    
    static func changeShoutLocationController() -> SelectShoutLocationViewController {
        return storyboard(.Location).instantiateViewController(withIdentifier: "ShoutLocationController") as! SelectShoutLocationViewController
    }
    
    static func shoutConfirmationController() -> ShoutConfirmationViewController {
        return storyboard(.Shout).instantiateViewController(withIdentifier: "shoutConfirmation") as! ShoutConfirmationViewController
    }
    
    static func editShoutController() -> EditShoutParentViewController {
        return storyboard(.Shout).instantiateViewController(withIdentifier: "editShoutTableViewController") as! EditShoutParentViewController
    }
    
    static func suggestionsController() -> SuggestedProfilesTableViewController {
        return storyboard(.InviteFriends).instantiateViewController(withIdentifier: "SuggestionsTableViewController") as! SuggestedProfilesTableViewController
    }
    
    static func createShoutWithTypeController(_ type: ShoutType) -> CreateShoutParentViewController {
        let controller =  storyboard(.Shout).instantiateViewController(withIdentifier: "createShoutParentController") as! CreateShoutParentViewController

        controller.type = type
        
        return controller
    }
    
    static func selectShoutAttachmentController() -> ConversationSelectShoutController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationSelectShoutController") as! ConversationSelectShoutController
    }
    
    static func conversationSelectProfileAttachmentParentController() -> ConversationSelectProfileAttachmentViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationSelectProfileAttachmentViewController") as! ConversationSelectProfileAttachmentViewController
    }
    
    static func conversationSelectProfileAttachmentController() -> ProfilesListTableViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ProfilesListTableViewController") as! ProfilesListTableViewController
    }
    
    static func profileListController() -> ProfilesListTableViewController {
        return storyboard(.InviteFriends).instantiateViewController(withIdentifier: "ProfilesListTableViewController") as! ProfilesListTableViewController
    }
    
    static func facebookProfileListController() -> FacebookFriendsListParentViewController {
        return storyboard(.InviteFriends).instantiateViewController(withIdentifier: "FacebookFriendsListParentViewController") as! FacebookFriendsListParentViewController
    }
    
    static func notificationsController() -> NotificationsTableViewController {
        return storyboard(.Notifications).instantiateInitialViewController() as! NotificationsTableViewController
    }
    
    static func conversationController() -> ConversationViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "conversationController") as! ConversationViewController
    }
    
    static func conversationInfoController() -> ConversationInfoViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "conversationInfoController") as! ConversationInfoViewController
    }
    
    static func conversationAttachmentController() -> ConversationAttachmentViewController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationAttachmentViewController") as! ConversationAttachmentViewController
    }
    
    static func conversationLocationController() -> ConversationLocationController {
        return storyboard(.Chats).instantiateViewController(withIdentifier: "ConversationLocationController") as! ConversationLocationController
    }
    
    static func videoCallController() -> VideoCallViewController {
        return storyboard(.VideoCalls).instantiateViewController(withIdentifier: "VideoCallViewController") as! VideoCallViewController
    }
    
    static func incomingCallController() -> IncomingCallController {
        return storyboard(.VideoCalls).instantiateViewController(withIdentifier: "IncomingCallController") as! IncomingCallController
    }
    
    // MARK: - Promote stroyboard
    
    static func promoteShoutTableViewController() -> PromoteShoutTableViewController {
        return storyboard(.Promote).instantiateViewController(withIdentifier: "PromoteShoutTableViewController") as! PromoteShoutTableViewController
    }
    
    static func promotedShoutViewController() -> PromotedShoutViewController {
        return storyboard(.Promote).instantiateViewController(withIdentifier: "PromotedShoutViewController") as! PromotedShoutViewController
    }
    
    // MARK: - Pages storyboard
    
    static func pagesListParentViewController() -> PagesListParentViewController {
        return storyboard(.Pages).instantiateViewController(withIdentifier: "PagesListParentViewController") as! PagesListParentViewController
    }
    
    static func myPagesTableViewController() -> MyPagesTableViewController {
        return storyboard(.Pages).instantiateViewController(withIdentifier: "MyPagesTableViewController") as! MyPagesTableViewController
    }
    
    static func publicPagesTableViewController() -> PublicPagesTableViewController {
        return storyboard(.Pages).instantiateViewController(withIdentifier: "PublicPagesTableViewController") as! PublicPagesTableViewController
    }

    static func createPageViewController() -> CreatePageViewController {
        return storyboard(.Pages).instantiateViewController(withIdentifier: "CreatePageViewController") as! CreatePageViewController
    }
    
    static func createPageInfoViewController() -> CreatePageInfoViewController {
        return storyboard(.Pages).instantiateViewController(withIdentifier: "CreatePageInfoViewController") as! CreatePageInfoViewController
    }
    
    // MARK: - Admins storyboard
    
    static func adminsListParentViewController() -> AdminsListParentViewController {
        return storyboard(.Admins).instantiateViewController(withIdentifier: "AdminsListParentViewController") as! AdminsListParentViewController
    }
    
    static func adminsListTableViewController() -> AdminsListTableViewController {
        return storyboard(.Admins).instantiateViewController(withIdentifier: "AdminsListTableViewController") as! AdminsListTableViewController
    }
    
    static func staticPageViewController() -> StaticPageViewController {
        return storyboard(.StaticPage).instantiateViewController(withIdentifier: "StaticPageViewController") as! StaticPageViewController
    }
    
    
}
