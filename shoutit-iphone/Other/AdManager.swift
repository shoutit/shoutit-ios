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
import CocoaLumberjackSwift

enum ShoutAdItemType {
    case shout
    case ad
}

enum ShoutAdItem {
    case shout(shout: ShoutitKit.Shout)
    case ad(ad: FBNativeAd)
    
    func  itemType() -> ShoutAdItemType {
        switch self {
        case shout( _):
            return .shout
        default:
            return .ad
        }
    }
}

class AdManager : NSObject, FBNativeAdDelegate  {
    
    var reloadCollection : (() -> Void)?
    var reloadIndexPath : (([IndexPath]) -> Void)?
    var loadedAds : [FBNativeAd]?
    var shouts : [Shout]?
    var shoutsSection : Int = 0
    var adPositionCycle: Int = 25
    
    func items() -> [ShoutAdItem] {
        // here you need to create array based on shouts and loadedAds
        var allItems : [ShoutAdItem] = []
        
        if let old = self.shouts {
            allItems.append(contentsOf: old.map{ShoutAdItem.shout(shout:$0)})
        }
        
        var adPosition: Int = 0
        
        for ad in self.loadedAds! {
            let position = (adPosition + 1) * adPositionCycle
            
            if position < allItems.count {
                allItems.insert(.ad(ad: ad), at: position)
            }
            
            adPosition = adPosition + 1
        }
        
        return allItems
    }
    
    override init() {
        super.init()
        self.loadedAds = []
    }
    
    func handleNewShouts(_ newShouts: [Shout]?) {
        self.shouts = newShouts
        
        if shouldLoadNextAd() {
            loadNextAd()
        }
    }
    
    func shouldLoadNextAd() -> Bool {
        return true
    }
    
    func loadNextAd() {
        let nativeAd = FBNativeAd(placementID: Constants.FacebookAudience.collectionAdID)
        nativeAd.delegate = self
        nativeAd.load()
    }
    
    func indexForItem(_ item: ShoutAdItem) -> Int? {
        var idx = 0
        for aItem in self.items() {
            if item.itemType() != aItem.itemType() {
                continue
            }

            guard case let .shout(shout) = item else {
                continue
            }
            
            guard case let .shout(rshout) = aItem else {
                continue
            }
            
            if shout == rshout {
                return idx
            }
            
            idx = idx + 1
            
        }
        
        return nil
    }
    
    func replaceItemAtIndex(_ idx: Int, withItem newShout: ShoutAdItem) {
        guard case .shout(let shout) = newShout else { return }
        
        self.shouts?[idx] = shout
        
        reloadIndexPath?([IndexPath(item: idx, section: self.shoutsSection)])
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        self.loadedAds?.append(nativeAd)
        
        reloadCollection?()
        DDLogVerbose("FACEBOOK_AUDIENCE: Ad Loaded - \(nativeAd.placementID)")
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: NSError) {
        DDLogError("FACEBOOK_AUDIENCE: \(error)")
    }
    
}
