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
    
    func addNextTextField(_ textField: UITextField, withDisposeBag disposeBag: DisposeBag) {
        self.rx_controlEvent(.editingDidEndOnExit)
            .subscribeNext{
                textField.becomeFirstResponder()
            }
            .addDisposableTo(disposeBag)
    }
    
    func addOnReturnAction(_ action: (Void) -> Void, withDisposeBag disposeBag: DisposeBag) {
        self.rx_controlEvent(.editingDidEndOnExit).subscribeNext(action).addDisposableTo(disposeBag)
    }
}
