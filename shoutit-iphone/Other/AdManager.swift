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
    var reloadIndexPath : (([NSIndexPath]) -> Void)?
    var loadedAds : [FBNativeAd]?
    var shouts : [Shout]?
    var shoutsSection : Int = 0
    var adPositionCycle: Int = 25
    
    func items() -> [ShoutAdItem] {
        // here you need to create array based on shouts and loadedAds
        var allItems : [ShoutAdItem] = []
        
        if let old = self.shouts {
            allItems.appendContentsOf(old.map{ShoutAdItem.Shout(shout:$0)})
        }
        
        var adPosition: Int = 0
        
        for ad in self.loadedAds! {
            let position = (adPosition + 1) * adPositionCycle
            
            if position < allItems.count {
                allItems.insert(.Ad(ad: ad), atIndex: position)
            }
            
            adPosition = adPosition + 1
        }
        
        return allItems
    }
    
    override init() {
        super.init()
        self.loadedAds = []
    }
    
    func handleNewShouts(newShouts: [Shout]?) {
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
    
    func replaceItemAtIndex(idx: Int, withItem newShout: ShoutAdItem) {
        guard case .Shout(let shout) = newShout else { return }
        
        self.shouts?[idx] = shout
        
        reloadIndexPath?([NSIndexPath(forItem: idx, inSection: self.shoutsSection)])
    }
    
    func nativeAdDidLoad(nativeAd: FBNativeAd) {
        self.loadedAds?.append(nativeAd)
        
        reloadCollection?()
        DDLogVerbose("FACEBOOK_AUDIENCE: Ad Loaded - \(nativeAd.placementID)")
    }
    
    func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError) {
        DDLogError("FACEBOOK_AUDIENCE: \(error)")
    }
    
}