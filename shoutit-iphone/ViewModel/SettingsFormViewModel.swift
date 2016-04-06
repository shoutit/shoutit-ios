//
//  SettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol SettingsFormViewModel {
    var title: String {get}
    var cellViewModels: [SettingsFormCellViewModel] {get set}
}
