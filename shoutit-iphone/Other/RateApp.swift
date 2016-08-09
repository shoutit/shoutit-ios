//
//  RateApp.swift
//  shoutit
//
//  Created by Piotr Bernad on 09/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

private let RateAppDefaultsNumberOfLaunchesKey = "RateAppDefaultsNumberOfLaunchesKey"
private let RateAppDefaultsNumberOfEventsKey = "RateAppDefaultsNumberOfEventsKey"
private let RateAppDefaultsPromptedKey = "RateAppDefaultsPromptedKey"
private let RateAppURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=947017118&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
let RateAppOpenFeedbackNotification = "RateAppOpenFeedbackNotification"

class RateApp {
    var usesUntilPrompt : Int = 10
    var eventsUntilPrompt : Int = 3
    
    static func sharedInstance() -> RateApp {
        if sharedInstanceStore == nil {
            sharedInstanceStore = RateApp()
        }
        
        return sharedInstanceStore!
    }
    
    private static var sharedInstanceStore: RateApp?
    
    
    func registerEvent() {
        let events = NSUserDefaults.standardUserDefaults().numberOfEvents() + 1
        NSUserDefaults.standardUserDefaults().setNumberOfEvents(events)
    }
    
    func registerLaunch() {
        let launches = NSUserDefaults.standardUserDefaults().numberOfLaunches() + 1
        NSUserDefaults.standardUserDefaults().setNumberOfLaunches(launches)
    }
    
    func shouldEnjoyPrompt() -> Bool {
        
        if NSUserDefaults.standardUserDefaults().alreadyPrompted() { return false }
        
        let launches = NSUserDefaults.standardUserDefaults().numberOfLaunches() + 1
        
        if launches > usesUntilPrompt {
            return true
        }
        
        
        return false
    }
    
    func shouldHelpfulPrompt() -> Bool {
        if NSUserDefaults.standardUserDefaults().alreadyPrompted() { return false }
        
        let events = NSUserDefaults.standardUserDefaults().numberOfEvents() + 1
        
        if events > eventsUntilPrompt {
            return true
        }
        
        return false
    }
    
    func resetCounters() {
        NSUserDefaults.standardUserDefaults().setNumberOfLaunches(0)
        NSUserDefaults.standardUserDefaults().setNumberOfEvents(0)
    }
    
    func promptEnjoyAlert(completion: ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Enjoying Shoutit Marketplace?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Rate App Alert Option"), style: .Default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Not really", comment: "Rate App Alert Option"), style: .Default, handler: { (action) in
            completion(false)
        }))
        
        return alert
    }
    
    func promptHelpfulAlert(completion: ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Do you think Shoutit is helpful?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Rate App Alert Option"), style: .Default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Not really", comment: "Rate App Alert Option"), style: .Default, handler: { (action) in
            completion(false)
        }))
        
        return alert
    }
    
    func promptRateAlert(completion: ((Bool) -> Void)) -> UIAlertController {
        
        let alert = UIAlertController(title: NSLocalizedString("How about a rating on the AppStore?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, sure", comment: "Rate App Alert Option"), style: .Default, handler: { [weak self] (action) in
            self?.openRateApp()
            NSUserDefaults.standardUserDefaults().setAlreadyPrompted(true)
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No, thanks", comment: "Rate App Alert Option"), style: .Default, handler: { [weak self] (action) in
            self?.resetCounters()
            completion(false)
        }))
        
        return alert
    }
    
    func promptFeedbackAlert(completion: ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Would you mind giving us some feedback?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, sure", comment: "Rate App Alert Option"), style: .Default, handler: { (action) in
            NSUserDefaults.standardUserDefaults().setAlreadyPrompted(true)
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No, thanks", comment: "Rate App Alert Option"), style: .Default, handler: { [weak self] (action) in
            self?.resetCounters()
            completion(false)
        }))
        
        return alert
    }
    
    func openRateApp() {
        UIApplication.sharedApplication().openURL(NSURL(string: RateAppURL)!)
    }
}

extension NSUserDefaults {
    
    
    func numberOfLaunches() -> Int {
        return (objectForKey(RateAppDefaultsNumberOfLaunchesKey) as? Int) ?? 0
    }
    
    func setNumberOfLaunches(launches: Int) {
        setObject(launches, forKey: RateAppDefaultsNumberOfLaunchesKey)
        synchronize()
    }
    
    func numberOfEvents() -> Int {
        return (objectForKey(RateAppDefaultsNumberOfEventsKey) as? Int) ?? 0
    }
    
    func setNumberOfEvents(events: Int) {
        setObject(events, forKey: RateAppDefaultsNumberOfEventsKey)
        synchronize()
    }
    
    func alreadyPrompted() -> Bool {
        return (objectForKey(RateAppDefaultsPromptedKey) as? Bool) ?? false
    }
    
    func setAlreadyPrompted(prompted: Bool) {
        setObject(prompted, forKey: RateAppDefaultsPromptedKey)
        synchronize()
    }
    
}