//
//  StaticPageViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class StaticPageViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView : UIWebView!

    weak var flowDelegate: FlowController?
    
    var urlToLoad : NSURL!
    var titleToShow : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: urlToLoad))
        
        self.navigationItem.title = self.titleToShow ?? ""
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.showErrorMessage(NSLocalizedString("Could not load content. Please try again late", comment: ""))
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.URL, path = url.absoluteString as? NSString else  { return true }
        
        if path.rangeOfString("shoutit.com").location == NSNotFound {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        
        return true
    }
}
