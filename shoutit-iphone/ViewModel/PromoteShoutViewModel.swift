//
//  PromoteShoutViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import RxSwift
import RxCocoa

class PromoteShoutViewModel {
    
    let shout: Shout
    
    init(shout: Shout) {
        self.shout = shout
    }
    
    func getPromotionLabels() -> Observable<[PromotionLabel]> {
        return APIShoutsService.getPromotionLabels()
    }
    
    func getPromotionOptions() -> Observable<[PromotionOption]> {
        return APIShoutsService.getPromotionOptions()
    }
}
