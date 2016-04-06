//
//  SettingsFormCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Validator

enum SettingsFormCellViewModel {
    case TextField(value: String?, placeholder: String, secureTextEntry: Bool, validator: (String -> ValidationResult)?)
    case Button(title: String, action: (Void -> Void))
}
