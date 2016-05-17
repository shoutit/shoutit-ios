//
//  NSURL+ImageVariation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public extension NSURL {
    
    func imageUrlByAppendingVaraitionComponent(varation: ImageVariation) -> NSURL {
        guard let fileExtension = pathExtension else { assertionFailure(); return self; }
        guard let originalPath = URLByDeletingPathExtension?.absoluteString else { assertionFailure(); return self; }
        guard let noExtensionURL = NSURL(string: originalPath + varation.pathComponent) else { assertionFailure(); return self; }
        return noExtensionURL.URLByAppendingPathExtension(fileExtension)
    }
}
