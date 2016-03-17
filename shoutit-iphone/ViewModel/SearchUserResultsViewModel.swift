//
//  SearchUserResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class SearchUserResultsViewModel {
    
    enum State {
        case Idle
        case Loading
        case Loaded(cells: [SearchUserProfileCellViewModel], page: Int)
        case NoContent
        case Error(ErrorType)
    }
    
    let searchPhrase: String
    
    // RX
    private let disposeBag = DisposeBag()
    private var requestDisposeBag = DisposeBag()
    private(set) var state: Variable<State> = Variable(.Idle)
    
    init(searchPhrase: String) {
        self.searchPhrase = searchPhrase
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        state.value = .Loading
        fetchPage(1)
    }
    
    func fetchNextPage() {
        guard case .Loaded(_, let page) = state.value else { return }
        fetchPage(page + 1)
    }
    
    // MARK: - Fetch
    
    private func fetchPage(page: Int) {
        
        requestDisposeBag = DisposeBag()
        
        fetchProfilesForPage(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let profiles):
                    self?.appendProfiles(profiles, forPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func fetchProfilesForPage(page: Int) -> Observable<[Profile]> {
        let params = SearchParams(phrase: searchPhrase, page: page, pageSize: 20)
        return APIProfileService.searchProfileWithParams(params)
    }
    
    // MARK: - Helpers
    
    private func appendProfiles(profiles: [Profile], forPage page: Int) {
        guard case .Loaded(var models, let page) = state.value else {
            assertionFailure()
            return
        }
        
        if profiles.count == 0 && page == 1 {
            state.value = .NoContent
        }
        
        models += profiles.map{SearchUserProfileCellViewModel(profile: $0)}
        state.value = State.Loaded(cells: models, page: page + 1)
    }
}
