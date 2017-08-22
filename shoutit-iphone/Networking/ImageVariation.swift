//
//  ImageVariation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public enum ImageVariation {
    case small
    case medium
    case large
    
    var pathComponent: String {
        switch self {
        case .small: return "_small"
        case .medium: return "_medium"
        case .large: return "_large"
        }
    }
    
    var size: CGSize {
        switch self {
        case .small: return CGSize(width: 240, height: 240)
        case .medium: return CGSize(width: 480, height: 480)
        case .large: return CGSize(width: 720, height: 720)
        }
    }
}
