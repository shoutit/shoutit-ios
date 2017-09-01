//
//  ShowDetailContainerViewController+AlertFactory.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 15.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension ShowDetailContainerViewController {
    
    func moreAlert(_ reportHandler: ((Void) -> Void)?, deleteHandler: ((Void) -> Void)?) -> UIAlertController {
        
        let alertTitle = NSLocalizedString("More", comment: "")
        let reportActionTitle = NSLocalizedString("Report Shout", comment: "")
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: reportActionTitle, style: .default) { (_) in reportHandler?() }
        let deleteAction = UIAlertAction(title: LocalizedString.delete, style: .destructive) { (_) in deleteHandler?() }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        reportAction.isEnabled = reportHandler != nil
        
        alertController.addAction(reportAction)
        if let _ = deleteHandler {
            alertController.addAction(deleteAction)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func deleteAlert(_ completion: @escaping () -> Void) -> UIAlertController {
        
        let alertTitle = NSLocalizedString("Are you sure?", comment: "")
        let alertMessage = NSLocalizedString("Do you want to delete this shout?", comment: "")
        let deleteButtonTitle = NSLocalizedString("Yes, Delete Shout", comment: "")
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .destructive) { (_) in completion() }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
