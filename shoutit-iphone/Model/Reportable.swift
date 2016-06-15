//
//  Reportable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

import Ogra

public protocol Reportable {
    func attachedObjectJSON() -> JSON
    func reportTitle() -> String
}

extension Reportable {
    public func reportAlert(completion: (report: Report) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: reportTitle(), message: NSLocalizedString("Please provide a report message", comment: ""), preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Please enter report message", comment: "")
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .Default, handler: { (action) in
            completion(report: Report(text: alertController.textFields?.first?.text ?? "", object: self))
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in }))
        
        return alertController
    }
}