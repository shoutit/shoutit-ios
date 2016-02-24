//
//  DiscoverViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol DiscoverRequest {
    func retriveDiscoverItems()
}

enum DiscoverSection : Int {
    case SubItems
    case Shouts
    
    func cellIdentifier() -> String {
        switch self {
        case SubItems: return DiscoverCollectionCellReuseIdentifier
        default: return DiscoverCollectionShoutsCellReuseIdentifier
        }
    }
    
    func headerIdentifier() -> String {
        switch self {
        case SubItems: return DiscoverCollectionHeaderReuseIdentifier
        default: return DiscoverCollectionShoutsHeaderReuseIdentifier
        }
    }
    
    func footerIdentifier() -> String {
        return DiscoverCollectionShoutsFooterReuseIdentifier
    }
}

private let DiscoverCollectionCellReuseIdentifier = "DiscoverCollectionCellReuseIdentifier"
private let DiscoverCollectionShoutsCellReuseIdentifier = "DiscoverCollectionShoutsCellReuseIdentifier"

private let DiscoverCollectionHeaderReuseIdentifier = "DiscoverCollectionHeaderReuseIdentifier"
private let DiscoverCollectionShoutsHeaderReuseIdentifier = "DiscoverCollectionShoutsHeaderReuseIdentifier"
private let DiscoverCollectionShoutsFooterReuseIdentifier = "DiscoverCollectionShoutsFooterReuseIdentifier"

class DiscoverViewModel: AnyObject, DiscoverRequest {
    let items = BehaviorSubject<DiscoverResult?>(value: nil)
    let shouts = BehaviorSubject<[Shout]?>(value: [])
    let displayable = DiscoverDisplayable()
    
    func retriveDiscoverItems() {
        fatalError("Not implemented")
    }
    
    func cellIdentifierForSection(section : Int) -> String {
        return DiscoverSection(rawValue: section)!.cellIdentifier()
    }
    
    func discoverItems() -> [DiscoverItem] {
        do {
            let result = try self.items.value()
            
            if let discoverResult = result {
                return discoverResult.retrivedItems ?? []
            }
            
            return []
        } catch {
            return []
        }
    }
    
    func mainItem() -> DiscoverItem? {
        do {
            let result = try self.items.value()
            
            if let discoverResult = result {
                return discoverResult.mainItem
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func shoutsItems() -> [Shout] {
        do {
            let result = try self.shouts.value()
            
            return result ?? []
        } catch {
            return []
        }
    }
}
