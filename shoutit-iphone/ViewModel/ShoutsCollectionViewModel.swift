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
        case ProfileShouts(user: Profile)
        case RelatedShouts(shout: Shout)
        case TagShouts(tag: Tag)
        case DiscoverItemShouts(discoverItem: DiscoverItem)
        case ConversationShouts(conversation: Conversation)
        case BookmarkedShouts(user: Profile)
        case HomeShouts
        
        func showAds() -> Bool {
            // turn of ads for given context if needed
            return true
        }
    }
    
    // consts
    let context: Context
    private(set) var pager: NumberedPagePager<ShoutCellViewModel, Shout>!
    
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
    
    func applyFilters(filtersState: FiltersState) {
        self.filtersState = filtersState
        reloadContent()
    }
    
    // MARK: - To display
    
    func sectionTitle() -> String {
        switch context {
        case .ProfileShouts(let user):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Shouts Controller Section Title"), user.firstName ?? user.name)
        case .RelatedShouts:
            return NSLocalizedString("Related Shouts", comment: "Shouts Controller Section Title")
        case .TagShouts(let tag):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Shouts Controller Section Title"), tag.name)
        case .DiscoverItemShouts(let discoverItem):
            return discoverItem.title
        case .ConversationShouts:
            return NSLocalizedString("Conversation Shouts", comment: "Shouts Controller Section Title")
        case .BookmarkedShouts:
            return NSLocalizedString("Bookmarked Shouts", comment: "Shouts Controller Section Title")
        case .HomeShouts:
            return NSLocalizedString("My Feed", comment: "Shouts Controller Section Title")
        }
        
    }
    
    func noContentMessage() -> String {
        switch context {
        case .HomeShouts: return NSLocalizedString("Nothing in your feed tap here to add some interests", comment: "Home No Items Placeholder")
        default: return NSLocalizedString("No results were found", comment: "Empty search results placeholder")
        }
    }
    
    func headerBackgroundColor() -> UIColor {
        switch context {
        case .HomeShouts:
            return UIColor(shoutitColor: .BackgroundLightGray)
        default:
            return UIColor.whiteColor()
        }
    }
    
    func subtitleHidden() -> Bool {
        switch context {
        case .HomeShouts:
            return true
        default:
            return false
        }
    }
    
    
    func resultsCountString() -> String {
        switch context {
        case .HomeShouts: return ""
        default: return String.localizedStringWithFormat(NSLocalizedString("%d Shouts", comment: "Search results count string"), numberOfResults ?? 0)
        }
    }
    
    func getFiltersState() -> FiltersState {
        return filtersState ?? FiltersState(location: (Account.sharedInstance.user?.location, .Enabled),
                                            withinDistance: (.Distance(kilometers: 20), .Enabled))
    }
    
    // MARK: Fetch
    
    func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>> {
        switch context {
        case .RelatedShouts(let shout):
            let params = RelatedShoutsParams(shout: shout, page: page, pageSize: pageSize)
            return APIShoutsService.relatedShoutsWithParams(params)
        case .ProfileShouts(let profile):
            var params = FilteredShoutsParams(username: profile.username, page: page, pageSize: pageSize, currentUserLocation: nil, skipLocation: true)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .TagShouts(let tag):
            var params = FilteredShoutsParams(tag: tag.name, page: page, pageSize: pageSize, currentUserLocation: Account.sharedInstance.user?.location, skipLocation: false)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .DiscoverItemShouts(let discoverItem):
            var params = FilteredShoutsParams(discoverId: discoverItem.id, page: page, pageSize: pageSize, skipLocation: true)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        case .ConversationShouts(let conversation):
            let params = PageParams(page: page, pageSize: pageSize)
            return APIChatsService.getShoutsForConversationWithId(conversation.id, params: params)
        case .BookmarkedShouts(let user):
            let params = PageParams(page: page, pageSize: pageSize)
            return APIShoutsService.getBookmarkedShouts(user, params: params)
        case .HomeShouts:
            let user = Account.sharedInstance.user
            if let user = user where user.isGuest == false {
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
