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
    private(set) var cellViewModels: [CreateShoutCellViewModel]
    private unowned var parent: CreateShoutViewModel
    
    init(cellViewModels: [CreateShoutCellViewModel], parent: CreateShoutViewModel) {
        self.cellViewModels = cellViewModels
        self.parent = parent
    }
    
    func togglePublishToFacebookFromViewController(controller: UIViewController) -> Observable<Bool> {
        
        return Observable.create{[weak self] (observer) -> Disposable in
            guard let `self` = self else { return NopDisposable.instance }
            let publish = self.parent.shoutParams.publishToFacebook.value
            let facebookManager = Account.sharedInstance.facebookManager
            if publish || facebookManager.hasPermissions(.PublishActions) {
                self.parent.shoutParams.publishToFacebook.value = !publish
                observer.onNext(!publish)
                observer.onCompleted()
                return NopDisposable.instance
            } else {
                return facebookManager.requestPublishPermissions([.PublishActions], viewController: controller).subscribe { (event) in
                    switch event {
                    case .Next:
                        
                    case .Error(let error):
                        observer.onError(error)
                    case .Completed:
                        observer.onCompleted()
                    }
                }
            }
        }
    }
}
