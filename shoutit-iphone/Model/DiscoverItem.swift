//
//  DiscoverItem.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Freddy

public struct DiscoverItem {
    public let id: String
    public let apiUrl: String
    public let title: String
    public let subtitle: String
    public let position: Int
    public let image: String
    public let icon: String
}

extension DiscoverItem: JSONDecodable {
    public init(json value: JSON) throws {
        id = try value.string("id")
        apiUrl = try value.string("api_url")
        title = try value.string("title")
        subtitle = try value.string("subtitle")
        position = try value.int("position")
        image = try value.string("image")
        icon = try value.string("icon")
    }
}
