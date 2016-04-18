//
//  ShoutConfirmationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShoutConfirmationViewController: UIViewController {

    var shout : Shout!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var createAnotherButton: CustomUIButton!
    @IBOutlet weak var descriptionlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hydrateViews()
        setupRx()
    }
    
    private func setupRx() {
        
        shareButton.rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.displayShareSheet()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func hydrateViews() {
        if shout.type()! == ShoutType.Offer {
            createAnotherButton.setTitle(NSLocalizedString("Create another Offer", comment: ""), forState: .Normal)
            if let title = shout.title {
                descriptionlabel.text = NSLocalizedString("Your offer \"\(title)\" will appear on Shoutit soon.", comment:"")
            } else {
                descriptionlabel.text = NSLocalizedString("Your offer will appear on Shoutit soon.", comment:"")
            }
            
        } else {
            createAnotherButton.setTitle(NSLocalizedString("Create another Request", comment: ""), forState: .Normal)
            if let title = shout.title {
                descriptionlabel.text = NSLocalizedString("Your request \"\(title)\" will appear on Shoutit soon.", comment:"")
            } else {
                descriptionlabel.text = NSLocalizedString("Your request will appear on Shoutit soon.", comment:"")
            }
        }
    }
    
    private func displayShareSheet() {
        let url = NSURL(string: shout.webPath)!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
}
