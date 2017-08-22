//
//  Transaction+AttributedStrings.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 15.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

extension Transaction {
    
    func attributedText() -> NSAttributedString? {
        
        if let display = self.display {
            let attributed = NSMutableAttributedString(string: display.text)
            
            guard let ranges = display.ranges else {
                return attributed
            }
            
            for range in ranges {
                attributed.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor(shoutitColor: .shoutitLightBlueColor)], range: NSMakeRange(range.offset, range.length))
            }
            
            return attributed
        }
        
        return nil
    }
}
