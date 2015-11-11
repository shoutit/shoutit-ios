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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "cancel:"), animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.htmlData != nil) {
            self.webView.loadData(self.htmlData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: NSURL(string: "http://www.shoutit.com")!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentFromViewController(parent: UIViewController, withHTMLFile: String) {
        if let vc = Constants.ViewControllers.MODEL_WEB_VIEW_CONTROLLER as? SHModalWebViewController, let contents = NSBundle.mainBundle().pathForResource(withHTMLFile, ofType: "html") {
            vc.htmlData = NSData(contentsOfFile: contents)
            let navController = UINavigationController(rootViewController: vc)
            parent.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    func presentFromViewController(parent: UIViewController, with HTMLString: String) {
        if let vc = Constants.ViewControllers.MODEL_WEB_VIEW_CONTROLLER as? SHModalWebViewController {
            vc.HTMLString = HTMLString
            vc.webView.loadHTMLString(HTMLString, baseURL: nil)
            let navController = UINavigationController(rootViewController: vc)
            parent.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
