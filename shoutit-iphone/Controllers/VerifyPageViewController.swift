//
//  VerifyPageViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 12/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class VerifyPageViewController: UITableViewController {

    var page : DetailedPageProfile!
    var verificationParams : PageVerificationParams!
    
    
    @IBOutlet weak var businessNameTextField: UITextField!
    
    @IBOutlet weak var contactPersonTextField: UITextField!
    
    @IBOutlet weak var contactNumberTextfield: UITextField!
    
    @IBOutlet weak var businessEmail: UITextField!
    
    @IBOutlet weak var locationButton: SelectionButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        verificationParams = PageVerificationParams()
       
    }

    @IBAction func changeLocationAction(sender: AnyObject) {
    }

    @IBAction func addPhotoAction(sender: AnyObject) {
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
