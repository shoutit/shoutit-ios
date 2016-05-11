//
//  ShoutsCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ShoutsCollectionViewModel: PagedShoutsViewModel {
    
    enum Context {
        case ProfileShouts(user: Profile)
        case RelatedShouts(shout: Shout)
        case TagShouts(tag: Tag)
        case DiscoverItemShouts(discoverItem: DiscoverItem)
    }
    
    // consts
    let context: Context
    
    // state
    var filtersState: FiltersState?
    var requestDisposeBag = DisposeBag()
    private(set) var state: Variable<PagedViewModelState<ShoutCellViewModel, Int, Shout>> = Variable(.Idle)
    
    // data
    var numberOfResults: Int? = 0
    
    init(context: Context) {
        self.context = context
    }
    
    func applyFilters(filtersState: FiltersState) {
        self.filtersState = filtersState
        reloadContent()
    }
    
    // MARK: - To display
    
    func sectionTitle() -> String {
        switch context {
        case .ProfileShouts(let user):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), user.firstName ?? user.name)
        case .RelatedShouts:
            return NSLocalizedString("Related Shouts", comment: "")
        case .TagShouts(let tag):
            return String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), tag.name)
        case .DiscoverItemShouts(let discoverItem):
            return discoverItem.title
        }
    }
    
    func resultsCountString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%d Shouts", comment: "Search results count string"), numberOfResults ?? 0)
    }
    
    func getFiltersState() -> FiltersState {
        return filtersState ?? FiltersState(location: (Account.sharedInstance.user?.location, .Enabled),
                                            withinDistance: (.Distance(kilometers: 20), .Enabled))
    }
    
    // MARK: Fetch
    
    func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>> {
        switch context {
        case .RelatedShouts(let shout):
            let params = RelatedShoutsParams(shout: shout, page: page, pageSize: pageSize, type: nil)
            return APIShoutsService.relatedShoutsWithParams(params)
        case .ProfileShouts(let profile):
            var params = FilteredShoutsParams(username: profile.username, page: page, pageSize: pageSize)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.searchShoutsWithParams(params)
        case .TagShouts(let tag):
            var params = FilteredShoutsParams(tag: tag.name, page: page, pageSize: pageSize)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.searchShoutsWithParams(params)
        case .DiscoverItemShouts(let discoverItem):
            var params = FilteredShoutsParams(discoverId: discoverItem.id, page: page, pageSize: pageSize)
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.searchShoutsWithParams(params)
        }
    }
}
