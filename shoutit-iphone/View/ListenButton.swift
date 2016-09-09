//
//  ListenButton.swift
//  shoutit
//
//  Created by Piotr Bernad on 09.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ListenButtonState {
    case Listen
    case Listening
}

class ListenButton: UIButton {

    var listenState : ListenButtonState = .Listen
    
}
