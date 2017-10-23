//
//  DeeplinkQueryParser.swift
//  shoutit
//
//  Created by Maciej Chmielewski on 23.10.2017.
//  Copyright © 2017 Shoutit. All rights reserved.
//

import Foundation

struct DeeplinkQueryParser {
    func parse(url: URL) -> [String: String]? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {return nil}
        let utmQueryItems: [(key: String, value: String)] = queryItems.flatMap{
            guard let value = $0.value else {return nil}
            return ($0.name, value)
        }
        return utmQueryItems.reduce([String: String]()) {dict, queryItem in
            var result = dict
            result[queryItem.key] = queryItem.value
            return result
        }
    }
}
