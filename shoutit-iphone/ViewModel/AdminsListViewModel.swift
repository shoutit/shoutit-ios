//
//  AdminsListViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

import RxSwift
import ShoutitKit

final class AdminsListViewModel {
    
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    let successSubject: PublishSubject<Success> = PublishSubject()
    let pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    let disposeBag = DisposeBag()
    
    init() {
        pager = NumberedPagePager(itemToCellViewModelBlock: {ProfilesListCellViewModel(profile: $0)},
                                  cellViewModelToItemBlock: {$0.profile},
                                  fetchItemObservableFactory: { APIPageService.getAdminsForPageWithUsername(Account.sharedInstance.user?.username ?? "me", pageParams: PageParams(page: $0, pageSize: 20)) },
                                  pageSize: 20)
    }
    
    func addAdmin(profile: Profile) {
        guard let username = Account.sharedInstance.user?.username else { return }
        let params = ProfileIdParams(id: profile.id)
        let observable = APIPageService.addProfileAsAdminWithParams(params, toPageWithUsername: username)
        triggerObservableAndRefreshUsersList(observable)
    }
    
    func removeAdmin(profile: Profile) {
        guard let username = Account.sharedInstance.user?.username else { return }
        let params = ProfileIdParams(id: profile.id)
        let observable = APIPageService.removeProfileAsAdminWithParams(params, toPageWithUsername: username)
        triggerObservableAndRefreshUsersList(observable)
    }
    
    private func triggerObservableAndRefreshUsersList(observable: Observable<Success>) {
        observable
            .subscribe { [weak self] (event) in
                switch event {
                case .Next(let success):
                    self?.successSubject.onNext(success)
                    self?.pager.refreshContent()
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
