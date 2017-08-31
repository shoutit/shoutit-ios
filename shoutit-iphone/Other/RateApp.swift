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
    
    fileprivate static var sharedInstanceStore: RateApp?
    
    
    func registerEvent() {
        let events = UserDefaults.standard.numberOfEvents() + 1
        UserDefaults.standard.setNumberOfEvents(events)
    }
    
    func registerLaunch() {
        let launches = UserDefaults.standard.numberOfLaunches() + 1
        UserDefaults.standard.setNumberOfLaunches(launches)
    }
    
    func shouldEnjoyPrompt() -> Bool {
        
        if UserDefaults.standard.alreadyPrompted() { return false }
        
        let launches = UserDefaults.standard.numberOfLaunches() + 1
        
        if launches > usesUntilPrompt {
            return true
        }
        
        
        return false
    }
    
    func shouldHelpfulPrompt() -> Bool {
        if UserDefaults.standard.alreadyPrompted() { return false }
        
        let events = UserDefaults.standard.numberOfEvents() + 1
        
        if events > eventsUntilPrompt {
            return true
        }
        
        return false
    }
    
    func resetCounters() {
        UserDefaults.standard.setNumberOfLaunches(0)
        UserDefaults.standard.setNumberOfEvents(0)
    }
    
    func promptEnjoyAlert(_ completion: @escaping ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Enjoying Shoutit Marketplace?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Rate App Alert Option"), style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Not really", comment: "Rate App Alert Option"), style: .default, handler: { (action) in
            completion(false)
        }))
        
        return alert
    }
    
    func promptHelpfulAlert(_ completion: @escaping ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Do you think Shoutit is helpful?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Rate App Alert Option"), style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Not really", comment: "Rate App Alert Option"), style: .default, handler: { (action) in
            completion(false)
        }))
        
        return alert
    }
    
    func promptRateAlert(_ completion: @escaping ((Bool) -> Void)) -> UIAlertController {
        
        let alert = UIAlertController(title: NSLocalizedString("How about a rating on the AppStore?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, sure", comment: "Rate App Alert Option"), style: .default, handler: { [weak self] (action) in
            self?.openRateApp()
            UserDefaults.standard.setAlreadyPrompted(true)
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No, thanks", comment: "Rate App Alert Option"), style: .default, handler: { [weak self] (action) in
            self?.resetCounters()
            completion(false)
        }))
        
        return alert
    }
    
    func promptFeedbackAlert(_ completion: @escaping ((Bool) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Would you mind giving us some feedback?", comment: "Rate App Alert Title"), message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, sure", comment: "Rate App Alert Option"), style: .default, handler: { (action) in
            UserDefaults.standard.setAlreadyPrompted(true)
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No, thanks", comment: "Rate App Alert Option"), style: .default, handler: { [weak self] (action) in
            self?.resetCounters()
            completion(false)
        }))
        
        return alert
    }
    
    func openRateApp() {
        UIApplication.shared.openURL(URL(string: RateAppURL)!)
    }
}

extension UserDefaults {
    
    
    func numberOfLaunches() -> Int {
        return (object(forKey: RateAppDefaultsNumberOfLaunchesKey) as? Int) ?? 0
    }
    
    func setNumberOfLaunches(_ launches: Int) {
        set(launches, forKey: RateAppDefaultsNumberOfLaunchesKey)
        synchronize()
    }
    
    func numberOfEvents() -> Int {
        return (object(forKey: RateAppDefaultsNumberOfEventsKey) as? Int) ?? 0
    }
    
    func setNumberOfEvents(_ events: Int) {
        set(events, forKey: RateAppDefaultsNumberOfEventsKey)
        synchronize()
    }
    
    func alreadyPrompted() -> Bool {
        return (object(forKey: RateAppDefaultsPromptedKey) as? Bool) ?? false
    }
    
    func setAlreadyPrompted(_ prompted: Bool) {
        set(prompted, forKey: RateAppDefaultsPromptedKey)
        synchronize()
    }
    
}
