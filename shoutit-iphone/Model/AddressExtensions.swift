//
//  AddressExtensions.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import GooglePlaces
import ShoutitKit

extension GooglePlaces.PlaceDetailsResponse.Result {
    func toAddressObject() -> Address {
        return Address(address: self.formattedAddress, city: "", country: "", latitude: self.geometryLocation?.latitude, longitude: self.geometryLocation?.longitude, postalCode: "", state: "")
    }
}