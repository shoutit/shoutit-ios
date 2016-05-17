//
//  ImageVariation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public enum ImageVariation {
    case Small
    case Medium
    case Large
    
    var pathComponent: String {
        switch self {
        case .Small: return "_small"
        case .Medium: return "_medium"
        case .Large: return "_large"
        }
    }
    
    var size: CGSize {
        switch self {
        case .Small: return CGSize(width: 240, height: 240)
        case .Medium: return CGSize(width: 480, height: 480)
        case .Large: return CGSize(width: 720, height: 720)
        }
    }
}