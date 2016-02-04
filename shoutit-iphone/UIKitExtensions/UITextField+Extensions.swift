//
//  UITextField+Extensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UITextField {
    
    func addNextTextField(textField: UITextField, withDisposeBag disposeBag: DisposeBag) {
        self.rx_controlEvent(.EditingDidEndOnExit)
            .subscribeNext{
                textField.becomeFirstResponder()
            }
            .addDisposableTo(disposeBag)
    }
    
    func addOnReturnAction(action: Void -> Void, withDisposeBag disposeBag: DisposeBag) {
        self.rx_controlEvent(.EditingDidEndOnExit).subscribeNext(action).addDisposableTo(disposeBag)
    }
}