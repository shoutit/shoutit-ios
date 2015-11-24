//
//  SHAmazonAWS.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AWSS3

class SHAmazonAWS: NSObject {

    private let SH_S3_USER_NAME = "shoutit-ios"
    private static let SH_S3_ACCESS_KEY_ID = "AKIAJW62O3PBJT3W3HJA"
    private static let SH_S3_SECRET_ACCESS_KEY = "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"
    
    private let SH_AMAZON_URL = "https://s3-eu-west-1.amazonaws.com/"
    private let SH_AWS_SHOUT_URL = "https://shout-image.static.shoutit.com/"
    private let SH_AWS_USER_URL = "https://user-image.static.shoutit.com/"
    
    static func configureS3() {
        let credsProvider = AWSStaticCredentialsProvider(accessKey: SH_S3_ACCESS_KEY_ID, secretKey: SH_S3_SECRET_ACCESS_KEY)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    static func generateKeyWithExtenstion(ext: String) -> String {
        return String(format: "%@-%d.%@", NSUUID().UUIDString, NSDate().timeIntervalSince1970, ext)
    }
    
    static func generateKey() -> String {
        return String(format: "%@-%d", NSUUID().UUIDString, NSDate().timeIntervalSince1970)
    }
    
}
