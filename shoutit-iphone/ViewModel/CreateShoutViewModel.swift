//
//  CreateShoutViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutViewModel: NSObject {
    func changeTypeActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Type", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Request", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Shout", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        
        return actionSheetController
    }
    
    func changeToRequest() {
        
    }
    
    func changeToShout() {
        
    }
}
