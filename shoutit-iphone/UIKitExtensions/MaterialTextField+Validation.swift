//
//  MaterialTextField+Validation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 03.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material

extension BorderedMaterialTextField {
    
    func addValidator(validator: (String -> ValidationResult), withDisposeBag disposeBag: DisposeBag) {
        
        self.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext{[unowned self] (email) in
                guard email.characters.count > 0 else {
                    self.detailLabelHidden = true
                    return
                }
                switch validator(email) {
                case .Valid:
                    self.detailLabelHidden = true
                case .Invalid(let error):
                    self.detailLabelHidden = false
                    self.detailLabel?.text = error.first?.message
                }
            }
            .addDisposableTo(disposeBag)
    }
}
