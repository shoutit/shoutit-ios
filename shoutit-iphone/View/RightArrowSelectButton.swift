//
//  RightArrowSelectButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class RightArrowSelectButton: SelectButton {
    override func selectImage() -> UIImage? {
        return UIImage(named: "forward_thin")
    }
}
