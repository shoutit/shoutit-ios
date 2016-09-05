//
//  HomeDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum HomeTab {
    case MyFeed
    case ShoutitPicks
    case Discover
}

class HomeDataSource {
    
    var active : Bool = false {
        didSet {
            self.activeComponents.each { (component) in
                component.active = active
            }
        }
    }
    
    var componentsChanged : ((([ComponentStackViewRepresentable])) -> Void)?
    
    var activeComponents : [BasicComponent] = [] {
        willSet {
            self.activeComponents.each { (component) in
                component.active = false
            }
        }
        
        didSet {
            self.activeComponents.each { (component) in
                component.active = self.active
            }
            
            var stackComponents : [ComponentStackViewRepresentable] = []
            
            self.activeComponents.each { (component) in
                if let stackComponent = component as? ComponentStackViewRepresentable {
                    stackComponents.append(stackComponent)
                }
            }
            
            self.componentsChanged?(stackComponents)
        }
    }
    
    lazy var myFeedComponents : [BasicComponent] = {
        return [HomeShoutsComponent(context: .HomeShouts)]
    }()
    
    lazy var shoutitPicksComponents : [BasicComponent] = {
        return [PublicChatsPreviewComponent(), ShoutsComponent(context: .HomeShouts)]
    }()
    
    lazy var discoverComponents : [BasicComponent] = {
        return [DiscoverComponent()]
    }()

    var currentTab : HomeTab = .MyFeed {
        didSet {
            
            switch currentTab {
            case .MyFeed:
                self.activeComponents = myFeedComponents
                break
            case .ShoutitPicks:
                self.activeComponents = shoutitPicksComponents
                break
            case .Discover:
                self.activeComponents = discoverComponents
                break
            }
            
            
        }
    }
    
}