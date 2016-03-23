//
//  ConversationLocationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationLocationCell: ConversationCell {

    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var locationSnapshot: UIImageView!
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    
    override func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
        
        guard let latitude = message.attachment()?.location?.latitude, longitude = message.attachment()?.location?.longitude else {
            return
        }
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        setMapSnapshotWithCoordinate(coordinates)
    }
    
    func setImageWith(imgview: UIImageView, message: Message) {
        if let imagePath = message.user?.imagePath, imgUrl = NSURL(string: imagePath) {
            imgview.sh_setImageWithURL(imgUrl, placeholderImage: nil)
        } else {
            hideImageView()
        }
    }
    
    func hideImageView() {
        avatarImageView?.hidden = true
        
        imageHeightConstraint?.constant = 5.0
        
        layoutIfNeeded()
    }
    
    func unHideImageView() {
        avatarImageView?.hidden = false
        
        imageHeightConstraint?.constant = 40.0
        
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        unHideImageView()
    }
    
    func setMapSnapshotWithCoordinate(coordinates: CLLocationCoordinate2D) {
        let options = MKMapSnapshotOptions()
        
        options.size = self.locationSnapshot.frame.size
        
        options.region = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
        
        let snapshooter = MKMapSnapshotter(options: options)
        
        snapshooter.startWithCompletionHandler { [weak self] (snapshot, error) in
            self?.locationSnapshot.image = snapshot?.image
        }
        
    }
}

