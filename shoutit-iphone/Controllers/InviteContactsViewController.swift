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

class InviteContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myContacts : [ContactProtocol]?
    private var addressBook : AddressBook?
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        guard let contact = myContacts?[indexPath.row] else {
            return cell
        }
        
        cell.textLabel!.text = "\(contact.firstName ?? "") \(contact.lastName ?? "")"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myContacts?.count ?? 0
    }
    
    func showMessageComposerForPhoneNumber(phone: String) {
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(phone)
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertView(title: NSLocalizedString("Cannot Send Text Message", comment: "Invite Contacts send message error title"), message: NSLocalizedString("Your device is not able to send text messages.", comment: "Invite Contacts send message error message"), delegate: self, cancelButtonTitle: LocalizedString.ok)
            errorAlert.show()
        }
    }
    
    func showPhoneActionSheet(phoneNumbers: [String]) {
        let optionMenu = UIAlertController(title: NSLocalizedString("Please select phone number", comment: "Invite Contacts Select Phone Number Alert Title"), message:nil, preferredStyle: .ActionSheet)
        
        phoneNumbers.each { (phone) in
            optionMenu.addAction(UIAlertAction(title: phone, style: .Default, handler: { (action) in
                self.showMessageComposerForPhoneNumber(phone)
            }))
        }
        
        optionMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Invite Contacts Select Phone Cancel"), style: .Cancel, handler: nil))
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
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

