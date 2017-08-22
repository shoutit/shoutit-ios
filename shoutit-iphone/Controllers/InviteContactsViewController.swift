//
//  InviteContactsViewController.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 29/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import AddressBook
import MessageUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class InviteContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myContacts : [ContactProtocol]?
    fileprivate var addressBook : AddressBook?
    let messageComposer = MessageComposer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Invite Contacts", comment: "Invite Contacts screen title")
        extractContacts()
    }
    
    func extractContacts(){
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        showProgressHUD()
        
        do {
            addressBook = try AddressBook()
            
            addressBook?.requestAccessToAddressBook({ [weak self] (access, error) -> Void in
                
                let queryBuilder = self?.addressBook?.queryBuilder()
                
                queryBuilder?.queryAsync({ (results, error) in
                    guard let contacts = results else {
                        self?.hideProgressHUD()
                        self?.showErrorMessage(NSLocalizedString("We couldn't find any contacts in your address book", comment: "Invite Contacts error message"))
                        return
                    }
                    self?.myContacts = contacts
                    self?.tableView.reloadData()
                    self?.hideProgressHUD()
                })
                
            })
        } catch {
            hideProgressHUD()
            showErrorMessage(NSLocalizedString("We can't access your contacts book. Please go to Settings and make sure that you grant access for Shoutit app.", comment: "Invite Contacts error message"))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        guard let contact = myContacts?[indexPath.row] else {
            return cell
        }
        
        cell.textLabel!.text = "\(contact.firstName ?? "") \(contact.lastName ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myContacts?.count ?? 0
    }
    
    func showMessageComposerForPhoneNumber(_ phone: String) {
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(phone)
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertView(title: NSLocalizedString("Cannot Send Text Message", comment: "Invite Contacts send message error title"), message: NSLocalizedString("Your device is not able to send text messages.", comment: "Invite Contacts send message error message"), delegate: self, cancelButtonTitle: LocalizedString.ok)
            errorAlert.show()
        }
    }
    
    func showPhoneActionSheet(_ phoneNumbers: [String]) {
        let optionMenu = UIAlertController(title: NSLocalizedString("Please select phone number", comment: "Invite Contacts Select Phone Number Alert Title"), message:nil, preferredStyle: .actionSheet)
        
        phoneNumbers.each { (phone) in
            optionMenu.addAction(UIAlertAction(title: phone, style: .default, handler: { (action) in
                self.showMessageComposerForPhoneNumber(phone)
            }))
        }
        
        optionMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Invite Contacts Select Phone Cancel"), style: .cancel, handler: nil))
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let contact = myContacts?[indexPath.row] else {
            return
        }
        
        if contact.phoneNumbers?.count > 0 {
            var phoneNumbers : [String] = []
            
            contact.phoneNumbers?.each({ (record) in
                if let singlePhoneNumber = record.value as? String {
                    phoneNumbers.append(singlePhoneNumber)
                }
            })
            
            if phoneNumbers.count > 1 {
                showPhoneActionSheet(phoneNumbers)
            } else {
                if let phone = phoneNumbers.first {
                    showMessageComposerForPhoneNumber(phone)
                }
            }
            
        } else {
            guard let phone = contact.phoneNumbers?.first?.value as? String else {
                return
            }
            
            showMessageComposerForPhoneNumber(phone)
        }

    }
    
}

