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
    var startedListeningMessage: String { get }
    var stoppedListeningMessage: String { get }
    func listenRequestObservable() -> Observable<Success>
}

extension Listenable {
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, error: ErrorType?)> {
        
        return Observable.create{[weak self] (observer) -> Disposable in
            
            guard let `self` = self else {
                return NopDisposable.instance
            }
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, error: nil))
            
            let subscribeBlock: (RxSwift.Event<Success> -> Void) = {(event) in
                switch event {
                case .Completed:
                    let message = self.isListening ? self.startedListeningMessage : self.stoppedListeningMessage
                    observer.onNext((listening: self.isListening, successMessage: message, error: nil))
                    observer.onCompleted()
                case .Error(let error):
                    self.isListening = !self.isListening
                    observer.onNext((listening: self.isListening, successMessage: nil, error: error))
                    observer.onError(error)
                default:
                    break
                }
            }
            
            return self.listenRequestObservable().subscribe(subscribeBlock)
        }
    }
}
