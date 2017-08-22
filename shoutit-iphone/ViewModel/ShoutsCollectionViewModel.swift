//
//  ShoutsCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class ShoutsCollectionViewModel: PagedShoutsViewModel {
    
    enum Context {
        case profileShouts(user: Profile)
        case relatedShouts(shout: Shout)
        case tagShouts(tag: Tag)
        case discoverItemShouts(discoverItem: DiscoverItem)
        case conversationShouts(conversation: Conversation)
        case bookmarkedShouts(user: Profile)
        case homeShouts
        
        func showAds() -> Bool {
            // turn of ads for given context if needed
            return true
        }
    }
    
    // consts
    let context: Context
    fileprivate(set) var pager: NumberedPagePager<ShoutCellViewModel, Shout>!
    
    // state
    var filtersState: FiltersState?
    
    init(context: Context) {
        self.context = context
        self.pager = NumberedPagePager(itemToCellViewModelBlock: {ShoutCellViewModel(shout: $0)},
                                       cellViewModelToItemBlock: {$0.shout!},
                                       fetchItemObservableFactory: {self.fetchShoutsAtPage($0)},
                                       showAds: self.context.showAds()
        )
    }
    
    func applyFilters(_ filtersState: FiltersState) {
        self.filtersState = filtersState
        reloadContent()
    }
    
    // MARK: - To display
    
    func sectionTitle() -> String {
        switch context {
        case .profileShouts(let user):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Shouts Controller Section Title"), user.firstName ?? user.name)
        case .relatedShouts:
            return NSLocalizedString("Related Shouts", comment: "Shouts Controller Section Title")
        case .tagShouts(let tag):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Shouts Controller Section Title"), tag.name)
        case .discoverItemShouts(let discoverItem):
            return discoverItem.title
        case .conversationShouts:
            return NSLocalizedString("Conversation Shouts", comment: "Shouts Controller Section Title")
        case .bookmarkedShouts:
            return NSLocalizedString("Bookmarked Shouts", comment: "Shouts Controller Section Title")
        case .homeShouts:
            return NSLocalizedString("My Feed", comment: "Shouts Controller Section Title")
        }
        
    }
    
    func noContentMessage() -> String {
        switch context {
        case .homeShouts: return NSLocalizedString("Nothing in your feed tap here to add some interests.", comment: "Home No Items Placeholder")
        default: return NSLocalizedString("No results were found", comment: "Empty search results placeholder")
        }
    }
    
    func headerBackgroundColor() -> UIColor {
        switch context {
        case .homeShouts:
            return UIColor(shoutitColor: .backgroundLightGray)
        default:
            return UIColor.white
        }
    }
    
    func subtitleHidden() -> Bool {
        switch context {
        case .homeShouts:
            return true
        default:
            return false
        }
    }
    
    
    func resultsCountString() -> String {
        switch context {
        case .homeShouts: return ""
        default: return String.localizedStringWithFormat(NSLocalizedString("%d Shouts", comment: "Search results count string"), numberOfResults ?? 0)
        }
    }
    
    func getFiltersState() -> FiltersState {
        return filtersState ?? FiltersState(location: (Account.sharedInstance.user?.location, .enabled),
                                            withinDistance: (.distance(kilometers: 20), .enabled))
    }
    
    // MARK: Fetch
    
    func fetchShoutsAtPage(_ page: Int) -> Observable<PagedResults<Shout>> {
        switch context {
        case .relatedShouts(let shout):
            let params = RelatedShoutsParams(shout: shout, page: page, pageSize: pageSize)
            return APIShoutsService.relatedShoutsWithParams(params)
        case .profileShouts(let profile):
            var params = FilteredShoutsParams(username: profile.username, page: page, pageSize: pageSize, currentUserLocation: nil, skipLocation: true)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .tagShouts(let tag):
            var params = FilteredShoutsParams(tag: tag.name, page: page, pageSize: pageSize, currentUserLocation: Account.sharedInstance.user?.location, skipLocation: false)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .discoverItemShouts(let discoverItem):
            var params = FilteredShoutsParams(discoverId: discoverItem.id, page: page, pageSize: pageSize, skipLocation: true)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .conversationShouts(let conversation):
            let params = PageParams(page: page, pageSize: pageSize)
            return APIChatsService.getShoutsForConversationWithId(conversation.id, params: params)
        case .bookmarkedShouts(let user):
            let params = PageParams(page: page, pageSize: pageSize)
            return APIShoutsService.getBookmarkedShouts(user, params: params)
        case .homeShouts:
            let user = Account.sharedInstance.user
            if let user = user, user.isGuest == false {
                var params = FilteredShoutsParams(page: page, pageSize: 20, skipLocation: true)
                if let filtersState = filtersState {
                    let filterParams = filtersState.composeParams()
                    params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
                }
                return APIProfileService.homeShoutsWithParams(params)
            } else {
                var params = FilteredShoutsParams(page: page, pageSize: 20, useLocaleBasedCountryCodeWhenNil: true, currentUserLocation: Account.sharedInstance.user?.location, skipLocation: false, attachCityAndState: true)
                if let filtersState = filtersState {
                    let filterParams = filtersState.composeParams()
                    params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
                }
                return APIShoutsService.listShoutsWithParams(params)
            }
        }
    }
}
