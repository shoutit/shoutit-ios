//
//  CreateShoutSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

protocol CreateShoutSectionViewModel: class {
    var title: String { get }
    var cellViewModels: [CreateShoutCellViewModel] { get }
}
