//
//  ProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    init() {
        shoutsSection = ProfileCollectionViewModel.shoutsSectionWithModels([])
        pagesSection = ProfileCollectionViewModel.pagesSectionWithModels(Account.sharedInstance.user?.pages ?? [])
    }
    
    var user: User {
        return Account.sharedInstance.user!
    }
    
    private(set) var pagesSection: ProfileCollectionSectionViewModel
    private(set) var shoutsSection: ProfileCollectionSectionViewModel
    
    // MARK: - ProfileCollectionViewModelInterface
    var configuration: ProfileCollectionViewConfiguration {
        return .MyProfile
    }
    
    // user data
    var name: String? {
        return user.name
    }
    
    var username: String? {
        return user.username
    }
    
    var isListeningToYou: Bool? {
        return false
    }
    
    var avatarURL: NSURL? {
        return (user.imagePath != nil) ? NSURL(string: user.imagePath!) : nil
    }
    
    var coverURL: NSURL? {
        return (user.coverPath != nil) ? NSURL(string: user.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(user.listenersCount)
        let listeningCountString = NumberFormatters.sharedInstance.numberToShortString(user.listeningMetadata.users)
        let interestsCountString = NumberFormatters.sharedInstance.numberToShortString(user.listeningMetadata.tags)
        return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString), .Notification, .EditProfile]
    }
    
    var descriptionText: String? {
        return user.bio
    }
    
    var websiteString: String? {
        return user.website
    }
    
    var dateJoinedString: String? {
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(user.dateJoindedEpoch)
    }
    
    var locationString: String? {
        return user.location.city
    }
    
    var locationFlagURL: NSURL? {
        return nil
    }
    
    func hasContentToDisplayInSection(section: Int) -> Bool {
        if section == 0 {
            return pagesSection.cells.count > 0
        }
        if section == 1 {
            return shoutsSection.cells.count > 1
        }
        return false
    }
    
    // MARK: - Helpers
    
    private static func pagesSectionWithModels(pages: [Profile]) -> ProfileCollectionSectionViewModel {
        let cells = pages.map{ProfileCollectionPageCellViewModel(profile: $0)}
        let title = NSLocalizedString("My Pages", comment: "")
        let footerTitle = NSLocalizedString("Create Page", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Green)
    }
    
    private static func shoutsSectionWithModels(shouts: [Shout]) -> ProfileCollectionSectionViewModel {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = NSLocalizedString("My Shouts", comment: "")
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Gray)
    }
}
