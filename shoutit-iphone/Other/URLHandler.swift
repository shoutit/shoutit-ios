//
//  URLHandler.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 21.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct URLHandler {
    
    static func callPhoneNumberWithString(_ phoneNumber: String) {
        let path = "telprompt://" + phoneNumber
        guard let url = URL(string: path) else { return }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    static func openSafariWithPath(_ p: String) {
        var path = p.lowercased()
        switch ShoutitValidator.validateEmail(path) {
        case .valid:
            path = "mailto:?to=\(path)"
        default:
            break
        }
        guard var url = URL(string: path) else { return }
        if url.scheme?.utf16.count == 0 {
            url = URL(string: "http://\(url.absoluteString)")!
        }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
