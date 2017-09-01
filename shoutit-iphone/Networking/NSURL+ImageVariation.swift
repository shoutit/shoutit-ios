//
//  NSURL+ImageVariation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public extension URL {
    
    func imageUrlByAppendingVaraitionComponent(_ varation: ImageVariation) -> URL {
        let fileExtension = pathExtension
        let originalPath = deletingPathExtension().absoluteString
        
        guard let noExtensionURL = URL(string: originalPath + varation.pathComponent) else { assertionFailure(); return self; }
        return noExtensionURL.appendingPathExtension(fileExtension)
    }
}
