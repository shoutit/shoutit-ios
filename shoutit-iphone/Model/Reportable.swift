//
//  Reportable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public protocol Reportable {
    
    func reportTitle() -> String
    
    var id: String { get }
    var reportTypeKey: String { get }
}

extension Reportable {
    public func reportAlert(_ completion: @escaping (_ report: Report) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: reportTitle(), message: NSLocalizedString("Please provide a report message", comment: ""), preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Please enter report message", comment: "")
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { (action) in
            completion(Report(text: alertController.textFields?.first?.text ?? "", object: self))
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
        
        return alertController
    }
}
