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
        guard let fileExtension = pathExtension else { assertionFailure(); return self; }
        guard let originalPath = deletingPathExtension().absoluteString else { assertionFailure(); return self; }
        guard let noExtensionURL = URL(string: originalPath + varation.pathComponent) else { assertionFailure(); return self; }
        return noExtensionURL.appendingPathExtension(fileExtension)
    }
}
