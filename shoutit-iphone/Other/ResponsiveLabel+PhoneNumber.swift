//
//  ResponsiveLabel+PhoneNumber.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 21.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ResponsiveLabel

extension ResponsiveLabel {
    
    func enablePhoneNumberDetectionWithAttribtues(attributes: [NSObject : AnyObject]) {
        let types: NSTextCheckingType = [.PhoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return }
        let patternDescriptor = PatternDescriptor(regex: detector, withSearchType: .All, withPatternAttributes: attributes)
        enablePatternDetection(patternDescriptor)
    }
}
