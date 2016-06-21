//
//  URLHandler.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 21.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct URLHandler {
    
    static func callPhoneNumberWithString(phoneNumber: String) {
        let path = "telprompt://" + phoneNumber
        guard let url = NSURL(string: path) else { return }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    static func openSafariWithPath(p: String) {
        var path = p.lowercaseString
        switch Validator.validateEmail(path) {
        case .Valid:
            path = "mailto:?to=\(path)"
        default:
            if !path.hasPrefix("http://") {
                path = "http://" + path
            }
        }
        guard let url = NSURL(string: path) else { return }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
