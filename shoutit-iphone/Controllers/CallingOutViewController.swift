//
//  CallingOutViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class CallingOutViewController: UIViewController {

    weak var flowDelegate: FlowController?
    
    var callingToProfile: Profile!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let localMedia = TWCLocalMedia()
        
        
        Account.sharedInstance
            .twilioManager
            .makeCallTo(callingToProfile, media: localMedia).subscribe({[weak self] (event) in
                switch event {
                case .Error(let error):
                    self?.showError(error)
                case .Next(let conversation):
                    let controller = Wireframe.videoCallController()
                    controller.conversation = conversation
                    self?.presentViewController(controller, animated: true, completion: nil)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    func showError(error: NSError) {
        let alert = UIAlertController(title: NSLocalizedString("Could not establish connection right now.", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
