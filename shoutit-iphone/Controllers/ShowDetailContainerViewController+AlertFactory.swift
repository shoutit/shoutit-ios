//
//  ShowDetailContainerViewController+AlertFactory.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 15.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension ShowDetailContainerViewController {
    
    func moreAlert(reportHandler: (Void -> Void)?, deleteHandler: (Void -> Void)?) -> UIAlertController {
        
        let alertTitle = NSLocalizedString("More", comment: "")
        let reportActionTitle = NSLocalizedString("Report Shout", comment: "")
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .ActionSheet)
        let reportAction = UIAlertAction(title: reportActionTitle, style: .Default) { (_) in reportHandler?() }
        let deleteAction = UIAlertAction(title: LocalizedString.delete, style: .Destructive) { (_) in deleteHandler?() }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil)
        reportAction.enabled = reportHandler != nil
        
        alertController.addAction(reportAction)
        if let _ = deleteHandler {
            alertController.addAction(deleteAction)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func deleteAlert(completion: () -> Void) -> UIAlertController {
        
        let alertTitle = NSLocalizedString("Are you sure?", comment: "")
        let alertMessage = NSLocalizedString("Do you want to delete this shout?", comment: "")
        let deleteButtonTitle = NSLocalizedString("Yes, Delete Shout", comment: "")
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Destructive) { (_) in completion() }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
