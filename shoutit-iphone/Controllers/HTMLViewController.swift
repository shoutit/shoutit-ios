//
//  HTMLViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 03.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

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
        
        self.navigationController?.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HTMLViewController.done)), animated: true)
        
        guard let fileName = htmlFile else {
            assert(false)
            return
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            guard let file = Bundle.main.path(forResource: fileName.rawValue, ofType: "html"), let htmlData = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
                assert(false)
                return
            }
            
            DispatchQueue.main.async {[weak self] in
                self?.webView.load(htmlData, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: URL(string: Constants.URL.ShoutItWebsite)!)
            }
        }
    }
    
    // MARK: - Dismiss
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
}
