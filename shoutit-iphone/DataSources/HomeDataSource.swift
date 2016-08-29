//
//  HomeDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


class HomeDataSource : CompoundDataSource {
    convenience init() {
        

        self.init(subSources: [])
    }
}