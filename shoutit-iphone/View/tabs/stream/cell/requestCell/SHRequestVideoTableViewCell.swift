//
//  SHRequestVideoTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHRequestVideoTableViewCell: UITableViewCell, YTPlayerViewDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shoutTitleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var ytPlayerView: YTPlayerView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setShout(shout: SHShout) {
        self.backView.layer.borderWidth = 0.5
        self.backView.layer.cornerRadius = 2
        self.backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.backView.layer.shadowOffset = CGSizeMake(0, 0.5)
        self.backView.layer.masksToBounds = false
        self.backView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.backView.layer.shadowOpacity = 0.3
        self.backView.layer.shadowRadius = 1
        
        self.activityIndicatorView.startAnimating()
        self.shoutTitleLabel.text = shout.title
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            self.priceLabel.text = price
        }
        
        if shout.datePublished > 0 {
            self.timeLabel.text = NSDate(timeIntervalSince1970: shout.datePublished).timeAgoSimple
        } else {
            self.timeLabel.text = "-"
        }

        self.locationLabel.text = shout.location?.city
        self.userImageView.kf_setImageWithURL(NSURL(string: (shout.user?.image)!)!, placeholderImage: UIImage(named: "no_image_available"))
        self.backView.layer.cornerRadius = 1
        let playerVars = [  "playsinline": 1,
                            "modestbranding": 1,
                            "showinfo": 0,
                            "controls": 1,
                            "iv_load_policy": 3,
                            "rel": 0,
                            "theme": "light" ]
        self.ytPlayerView.delegate = self
        let videoID = self.getYoutubeVideoID(shout.videoUrl)
        self.ytPlayerView.loadWithVideoId(videoID, playerVars: playerVars)
    }
    
    func getYoutubeVideoID(url: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(?<=watch\\?v=|/videos/|embed\\/)[^#\\&\\?]*", options: NSRegularExpressionOptions.CaseInsensitive)
            if let match = regex.firstMatchInString(url, options: NSMatchingOptions.ReportProgress, range: NSRange(location: 0, length: url.characters.count)) {
                let videoIDRange = match.rangeAtIndex(0)
                let substringForFirstMatch = (url as NSString).substringWithRange(videoIDRange)
                return substringForFirstMatch
            }
        } catch {
            log.debug("YoutubeVideoUrl")
        }
        return ""
    }
}



