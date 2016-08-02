//
//  LocalizedString.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 15.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct LocalizedString {
    
    static var cancel: String { return NSLocalizedString("Cancel", comment: "Common Cancel") }
    static var delete: String { return NSLocalizedString("Delete", comment: "Common Delete") }
    static var ok: String { return NSLocalizedString("OK", comment: "Common OK") }
    static var edit: String { return NSLocalizedString("Edit", comment: "Common Edit") }
    static var done: String { return NSLocalizedString("Done", comment: "Common Done") }
    static var next: String { return NSLocalizedString("Next", comment: "Common Next") }
    
    static var linked: String { return NSLocalizedString("Linked", comment: "Linked Account Accessory Title") }
    static var notLinked: String { return NSLocalizedString("Not Linked", comment: "Linked Account Accessory Title") }
    
    struct Media {
        static var waitUntilUpload: String { return NSLocalizedString("Please wait for upload to finish", comment: "Message to user when he needs to wait until upload is finished") }
    }
}
