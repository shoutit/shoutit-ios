//
//  CreateShoutLocationSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class CreateShoutLocationSectionViewModel: CreateShoutSectionViewModel {
    
    // CreateShoutSectionViewModel
    var title: String {
        return " " + NSLocalizedString("LOCATION", comment: "Create Shout Details Section Title")
    }
    var cellViewModels: [CreateShoutCellViewModel]
    
    private unowned var parent: CreateShoutViewModel
    private let disposeBag = DisposeBag()
    
    init(cellViewModels: [CreateShoutCellViewModel], parent: CreateShoutViewModel) {
        self.cellViewModels = cellViewModels
        self.parent = parent
    }
}
