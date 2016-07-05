//
//  AdManager.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 04/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import FBAudienceNetwork
import ShoutitKit

enum ShoutAdItemType {
    case Shout
    case Ad
}

enum ShoutAdItem {
    case Shout(shout: ShoutitKit.Shout)
    case Ad(ad: FBNativeAd)
    
    func  itemType() -> ShoutAdItemType {
        switch self {
        case Shout( _):
            return .Shout
        default:
            return .Ad
        }
    }
}

class AdManager : NSObject, FBNativeAdDelegate  {
    
    var reloadCollection : (() -> Void)?
    var loadedAds : [FBNativeAd]?
    var shouts : [Shout]?
    var adPositionCycle: Int = 25
    
    func items() -> [ShoutAdItem] {
        // here you need to create array based on shouts and loadedAds
        var allItems : [ShoutAdItem] = []
        
        self.shouts?.each({ (shout) in
            allItems.append(.Shout(shout: shout))
        })
        
        var adPosition: Int = 0
        
        for ad in self.loadedAds! {
            adPosition = (adPosition + 1) * adPositionCycle
            if adPosition < allItems.count {
                allItems.insert(.Ad(ad: ad), atIndex: adPosition)
            }
        }
        
        self.loadedAds?.each({ (ad) in
            allItems.append(.Ad(ad: ad))
        })
        return allItems
    }
    
    override init() {
        super.init()
        self.loadedAds = []
    }
    
    func handleNewShouts(newShouts: [Shout]?) {
        shouts = newShouts
        
        if shouldLoadNextAd() {
            loadNextAd()
        }
    }
    
    func shouldLoadNextAd() -> Bool {
        
        
        
        
        return true
    }
    
    func loadNextAd() {
        // place here code for fetching ad, when its loaded pass it to loadedAds array

        let nativeAd = FBNativeAd(placementID: "1151546964858487_1245960432083806")
        nativeAd.delegate = self
        nativeAd.loadAd()
    }
    
    func indexForItem(item: ShoutAdItem) -> Int? {
        var idx = 0
        for aItem in self.items() {
            if item.itemType() != aItem.itemType() {
                continue
            }

            guard case let .Shout(shout) = item else {
                continue
            }
            
            guard case let .Shout(rshout) = aItem else {
                continue
            }
            
            if shout == rshout {
                return idx
            }
            
            idx = idx + 1
            
        }
        
        return nil
    }
    
    func replaceItemAtIndex(idx: Int, withItem: ShoutAdItem) {
        // we need to replace shout at index with incoming object
        
        
        // then call reload
        reloadCollection?()
    }
    
    func nativeAdDidLoad(nativeAd: FBNativeAd) {
        self.loadedAds?.append(nativeAd)
        
        reloadCollection?()
    }
    
}