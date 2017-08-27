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
import Validator

extension BorderedMaterialTextField {
    
    func addValidator(_ validator: @escaping ((String) -> ValidationResult), withDisposeBag disposeBag: DisposeBag) {
        
        self.rx.text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged( { (lhs, rhs) throws -> Bool in
                return lhs == rhs
            })
            .subscribe(onNext: {[unowned self] (email) in
                guard let email = email, email.characters.count > 0 else {
                    self.detailLabelHidden = true
                    return
                }
                switch validator(email) {
                case .valid:
                    self.detailLabelHidden = true
                case .invalid(let error):
                    self.detailLabelHidden = false
                    self.detailLabel?.text = error.first?.message
                }
            })
            .addDisposableTo(disposeBag)
    }
}
