//
//  CompoundDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

//class CompoundDataSource : BasicDataSource {
//
//    private var stateDisposeBag : DisposeBag! = DisposeBag()
//    
//    var subSources : [BasicDataSource]! {
//        didSet {
//            self.stateDisposeBag = DisposeBag()
//            
//            for source in subSources {
//                source.stateMachine.subject.asDriver(onErrorJustReturn: .Error).driveNext({ [weak self] (state) in
//                    self?.trackStateOfSubSources()
//                }).addDisposableTo(self.stateDisposeBag)
//            }
//        }
//    }
//    
//    override var active : Bool {
//        didSet {
//            for source in subSources {
//                source.active = active
//            }
//        }
//    }
//    
//    override func loadContent() {
//        // do nothing, load just subsources
//    }
//    
//    private func trackStateOfSubSources() {
//        let allStates = self.subSources.map{$0.stateMachine.currentState}.unique()
//        
//        if allStates.contains(.Error) {
//            self.stateMachine.currentState = .Error
//            return
//        }
//        
//        if allStates.contains(.Loading) {
//            self.stateMachine.currentState = .Loading
//            return
//        }
//        
//        if allStates.contains(.Refreshing) {
//            self.stateMachine.currentState = .Refreshing
//        }
//        
//        if allStates.count == 1 && allStates.first == .Loaded {
//            self.stateMachine.currentState = .Loaded
//            return
//        }
//        
//        if allStates.count == 1 && allStates.first == .NoContent {
//            self.stateMachine.currentState = .NoContent
//        }
//        
//        debugPrint(allStates)
//        debugPrint(self.stateMachine.currentState)
//        
//        assertionFailure("No Supported State for Compound Data Source")
//        
//    }
//}