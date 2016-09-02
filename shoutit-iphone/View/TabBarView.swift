//
//  TabBarView.swift
//  shoutit
//
//  Created by Piotr Bernad on 02.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class TabBarView: UIView {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tabMarker: UIView!
    @IBOutlet weak var createButton: TabbarButton!

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        
        if view == self {
            return nil
        }
        
        return view
    }
}
