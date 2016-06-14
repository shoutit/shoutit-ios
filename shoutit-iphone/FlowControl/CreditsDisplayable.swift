//
//  CreditsDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 10/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol CreditsDisplayable {
    func showInviteFriends()
    func showCreditTransactions()
    func showPromotingShouts()
}

extension FlowController : CreditsDisplayable {
    func showInviteFriends() {
        let controller = Wireframe.inviteFriendsViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
        
    }
    
    func showCreditTransactions() {
        let controller = Wireframe.creditTransactionsViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showPromotingShouts() {
        let controller = Wireframe.creditPromotingShoutsInfoViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
}