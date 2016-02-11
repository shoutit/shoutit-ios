//
//  HTMLViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 03.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum BundledHTMLFile: String {
    case Policy = "policy"
    case Rules = "rules"
    case TermsOfService = "termsofservice"
}

final class HTMLViewController: UIViewController {
    
    @IBOutlet weak var webView : UIWebView!
    var htmlFile: BundledHTMLFile?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        
        navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done"), animated: true)
        
        guard let fileName = htmlFile else {
            assert(false)
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            guard let file = NSBundle.mainBundle().pathForResource(fileName.rawValue, ofType: "html"), let htmlData = NSData(contentsOfFile: file) else {
                assert(false)
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {[weak self] in
                self?.webView.loadData(htmlData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: NSURL(string: Constants.URL.ShoutItWebsite)!)
            }
        }
    }
    
    // MARK: - Dismiss
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
