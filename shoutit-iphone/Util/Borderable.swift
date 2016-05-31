//
//  Borderable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Borderable {
    weak var internalContentView: BorderedView! { get }
    func setBorders(cellIsFirst first: Bool, cellIsLast last: Bool) -> Void
}

extension Borderable where Self: UIView {
    
    func setBorders(cellIsFirst first: Bool, cellIsLast last: Bool) {
        var borders: UIRectEdge = [.Left, .Right]
        if first {
            borders = borders.union(.Top)
        }
        if last {
            borders = borders.union(.Bottom)
        }
        
        internalContentView.borders = borders
    }
}
