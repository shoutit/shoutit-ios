//
//  HomeShoutsData.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class HomeShoutsData: ShoutsDataSource {
    convenience override init() {
        self.init(context: .HomeShouts)
    }
}
