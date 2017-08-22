//
//  InvitationCode.swift
//  shoutit
//
//  Created by Piotr Bernad on 22.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct InvitationCode: Decodable {
    public let id: String
    public let createdAt: Int
    public let code: String
    

    public static func decode(_ j: JSON) -> Decoded<InvitationCode> {
        return curry(InvitationCode.init)
            <^> j <| "id"
            <*> j <| "created_at"
            <*> j <| "code"
    }
}
