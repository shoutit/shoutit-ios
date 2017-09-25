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
    
    var urlToLoad : URL!
    var titleToShow : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        self.webView.loadRequest(URLRequest(url: urlToLoad))
        
        self.self.navigationItem.titleLabel.text = self.titleToShow ?? ""
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.showErrorMessage(NSLocalizedString("Could not load content. Please try again late", comment: ""))
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url, let path = url.absoluteString as? NSString else  { return true }
        
        if path.range(of: "shoutit.com").location == NSNotFound {
            UIApplication.shared.openURL(url)
            return false
        }
        
        return true
    }
}
