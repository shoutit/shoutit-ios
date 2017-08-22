//
//  ResponsiveLabel+PhoneNumber.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 21.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension ResponsiveLabel {
    
    func enablePhoneNumberDetectionWithAttribtues(_ attributes: [AnyHashable: Any]) {
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return }
        let patternDescriptor = PatternDescriptor(regex: detector, withSearchType: .All, withPatternAttributes: attributes)
        enablePatternDetection(patternDescriptor)
    }
}
