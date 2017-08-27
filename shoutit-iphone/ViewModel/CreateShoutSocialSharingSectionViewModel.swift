//
//  CreateShoutSocialSharingSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class CreateShoutSocialSharingSectionViewModel: CreateShoutSectionViewModel {
    
    var title: String {
        return " " + NSLocalizedString("SHARING", comment: "Sharing section header on create shout")
    }
    fileprivate(set) var cellViewModels: [CreateShoutCellViewModel]
    fileprivate unowned var parent: CreateShoutViewModel
    fileprivate let disposeBag = DisposeBag()
    
    init(cellViewModels: [CreateShoutCellViewModel], parent: CreateShoutViewModel) {
        self.cellViewModels = cellViewModels
        self.parent = parent
    }
    
    func togglePublishToFacebookFromViewController(_ controller: UIViewController) {

        let publish = parent.shoutParams.publishToFacebook.value
        let facebookManager = Account.sharedInstance.facebookManager
        if publish || facebookManager.hasPermissions(.PublishActions) {
            parent.shoutParams.publishToFacebook.value = !publish
        } else {
            facebookManager
                .requestPublishPermissions([.PublishActions], viewController: controller)
                .subscribe {[weak self] (event) in
                    switch event {
                    case .Next:
                        self?.parent.shoutParams.publishToFacebook.value = !publish
                    case .Error(LocalError.Cancelled):
                        self?.parent.shoutParams.publishToFacebook.value = publish
                        break
                    case .error(let error):
                        self?.parent.errorSubject.onNext(error)
                    case .Completed:
                        break
                    }
                }
                .addDisposableTo(disposeBag)
        }
    }
}
