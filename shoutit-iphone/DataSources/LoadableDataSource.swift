//
//  BasicDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

enum LoadableContentState {
    case Initial
    case Loading
    case Refreshing
    case Loaded
    case NoContent
    case Error
}

class LoadableContentStateMachine {
    
    var currentState = LoadableContentState.Initial {
        willSet (newState) {
            if newState == currentState { return }
            
            guard let availableStates = self.validTransitions[currentState] else {
                assertionFailure("No States Provided")
                return
            }
            
            if availableStates.contains(newState) == false {
                assertionFailure("Not allowed transition between states")
                return
            }
        }
        
        didSet {
            if shouldLogStateChange {
                print("MACHINE STATE CHANGED: \(self.currentState)")
            }
            
            self.subject.onNext(currentState)
        }
    }
    
    var validTransitions : [LoadableContentState: [LoadableContentState]] =
                            [.Initial :     [.Loading],
                             .Loading :     [.Loaded, .NoContent, .Error],
                             .Refreshing :  [.Loaded, .NoContent, .Error],
                             .Loaded :      [.Refreshing, .Loaded, .Error],
                             .NoContent :   [.Refreshing, .Loaded, .Error],
                             .Error :  [.Loading, .Refreshing, .NoContent, .Error]]
    
    var shouldLogStateChange = false
    
    let subject : PublishSubject<LoadableContentState> = PublishSubject()
    
}

protocol LoadableDataSource {
    var stateMachine : LoadableContentStateMachine! { get }
    
    var active : Bool { get set }
    
    var shouldReloadOnActive : Bool { get set }
    
    func loadContent()
}