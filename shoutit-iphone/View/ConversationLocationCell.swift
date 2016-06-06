//
//  ConversationLocationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MapKit
import ShoutitKit

final class ConversationLocationCell: UITableViewCell, ConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var locationSnapshot: UIImageView!
    @IBOutlet weak var showLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicator?.hidden = false
        self.showLabel?.hidden = true
        unHideImageView()
    }
    
    func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
        
    
        self.activityIndicator?.startAnimating()
        self.showLabel?.hidden = true
        
        guard let latitude = message.attachment()?.location?.latitude, longitude = message.attachment()?.location?.longitude else {
            return
        }
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        setMapSnapshotWithCoordinate(coordinates)
    }
    
    func setMapSnapshotWithCoordinate(coordinates: CLLocationCoordinate2D) {
        let options = MKMapSnapshotOptions()
        
        options.size = self.locationSnapshot.frame.size
        
        options.region = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
        
        let snapshooter = MKMapSnapshotter(options: options)
        
        snapshooter.startWithCompletionHandler { [weak self] (snapshot, error) in
            self?.locationSnapshot.image = snapshot?.image
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.hidden = true
            self?.showLabel?.hidden = false
        }
        
    }
}

