//
//  Listenable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

protocol Listenable: class {
    var isListening: Bool { get set }
    func listenRequestObservable() -> Observable<ListenSuccess>
}

extension Listenable {
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, newListnersCount: Int?, error: Error?)> {
        
        return Observable.create{[weak self] (observer) -> Disposable in
            
            guard let `self` = self else {
                return Disposables.create {}
            }
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, newListnersCount:nil, error: nil))
            
            let subscribeBlock: ((RxSwift.Event<ListenSuccess>) -> Void) = {(event) in
                switch event {
                case .next(let success):
                    
                    observer.onNext((listening: self.isListening, successMessage: success.message, newListnersCount:success.newListnersCount, error: nil))
                    observer.onCompleted()
                case .error(let error):
                    self.isListening = !self.isListening
                    observer.onNext((listening: self.isListening, successMessage: nil, newListnersCount:nil, error: error))
                    observer.onError(error)
                default:
                    break
                }
            }
            
            return self.listenRequestObservable().subscribe(subscribeBlock)
        }
    }
}
