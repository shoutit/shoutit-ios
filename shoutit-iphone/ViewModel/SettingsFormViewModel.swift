//
//  SettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingsFormViewModel {
    
    var progressSubject: PublishSubject<Bool> {get}
    var successSubject: PublishSubject<Void> {get}
    var errorSubject: PublishSubject<ErrorType> {get}
    
    var title: String {get}
    var cellViewModels: [SettingsFormCellViewModel] {get set}
}
