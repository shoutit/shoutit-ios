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
    
    var user: User {
        return Account.sharedInstance.user!
    }
    
    private(set) var pages: [ProfileCollectionPageCellViewModel] = []
    private(set) var shouts: [ProfileCollectionShoutCellViewModel] = []
    
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
    var coverURL: NSURL? {
        return (user.coverPath != nil) ? NSURL(string: user.coverPath!) : nil
    }
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(user.listenersCount)
        let listeningCountString = NumberFormatters.sharedInstance.numberToShortString(user.listeningMetadata.users)
        let interestsCountString = NumberFormatters.sharedInstance.numberToShortString(user.listeningMetadata.tags)
        return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString)]
    }
    var descriptionText: String? {
        return user.bio
    }
    var websiteString: String? {
        return user.website
    }
    var dateJoinedString: String {
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(user.dateJoindedEpoch)
    }
    
    // sections
    private(set) var sections: [ProfileCollectionSectionViewModel] = []
}
