//
//  IncomingCallController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class IncomingCallController: UIViewController {

    var invitation : TWCIncomingInvite! {
        didSet {
            if #available(iOS 9.0, *) {
                loadViewIfNeeded()
            } else {
                if isViewLoaded() == false {
                    self.view.layoutIfNeeded()
                }
            }
            fetchCallingProfile()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var callTopicLabel: UILabel!
    @IBOutlet weak var callerAvatarImageView: UIImageView!
    @IBOutlet weak var incomingCallLabel: UILabel!
    
    var answerHandler : ((invitation: TWCIncomingInvite) -> Void)?
    var discardHandler : ((invitation: TWCIncomingInvite) -> Void)?

    @IBAction func discardAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { [weak self] in
            guard let `self` = self else { return }
            self.discardHandler?(invitation: self.invitation)
        }
    }
    
    @IBAction func answerAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { [weak self] in
            guard let `self` = self else { return }
            self.answerHandler?(invitation: self.invitation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitalViewConfiguration()
    }
    
    private func fetchCallingProfile() {
        APIProfileService
            .retrieveProfileWithTwilioUsername(invitation.from)
            .subscribeNext { [weak self] (profile) in
                self?.hydrateViewWithProfile(profile)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setInitalViewConfiguration() {
        incomingCallLabel.text = NSLocalizedString("Incoming Call", comment: "Incoming Call Title")
        callTopicLabel.text = nil
        callerAvatarImageView.image = nil
    }
    
    private func hydrateViewWithProfile(profile: Profile) {
        incomingCallLabel.text = NSLocalizedString("Incoming Call from ", comment: "Incoming Call Title From ") + "\(profile.fullName())"
        callerAvatarImageView.sh_setImageWithURL(profile.imagePath?.toURL(), placeholderImage: nil)
    }
}
