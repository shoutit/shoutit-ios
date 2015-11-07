//
//  SHModalWebViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHModalWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var HTMLString: String!
    var htmlData: NSData!
    let navigation = SHNavigation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "cancel:"), animated: true)
        if (self.htmlData != nil) {
            self.webView.loadData(self.htmlData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: NSURL(string: "http://www.shoutit.com")!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentFromViewController(parent: UIViewController, withHTMLFile: String) {
        let vc:SHModalWebViewController = navigation.viewControllerFromStoryboard("LoginStoryboard", withViewControllerId: "SHModalWebViewController") as! SHModalWebViewController
        vc.htmlData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(withHTMLFile, ofType: "html")!)
        let navController = UINavigationController(rootViewController: vc)
        parent.presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentFromViewController(parent: UIViewController, with HTMLString: String) {
        let vc: SHModalWebViewController = navigation.viewControllerFromStoryboard("LoginStoryboard", withViewControllerId: "SHModalWebViewController") as! SHModalWebViewController
        vc.HTMLString = HTMLString
        vc.webView.loadHTMLString(HTMLString, baseURL: nil)
        let navController: UINavigationController = UINavigationController(rootViewController: vc)
        parent.presentViewController(navController, animated: true, completion: nil)
    }
    
    func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
