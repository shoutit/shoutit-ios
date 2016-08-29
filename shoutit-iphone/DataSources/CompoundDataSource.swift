//
//  CompoundDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class CompoundDataSource : BasicDataSource {

    private var stateDisposeBag : DisposeBag! = DisposeBag()
    
    var subSources : [BasicDataSource]! {
        didSet {
            self.stateDisposeBag = DisposeBag()
            
            for source in subSources {
                source.stateMachine.subject.asDriver(onErrorJustReturn: .Error).driveNext({ [weak self] (state) in
                    self?.trackStateOfSubSources()
                }).addDisposableTo(self.stateDisposeBag)
            }
        }
    }
    
    override var active : Bool {
        didSet {
            for source in subSources {
                source.active = active
            }
        }
    }
    
    override func loadContent() {
        // do nothing, load just subsources
    }
    
    private func trackStateOfSubSources() {
        
    }
}