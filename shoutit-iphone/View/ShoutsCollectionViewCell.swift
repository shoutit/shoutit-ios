//
//  ProfileCollectionShoutsCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import FBAudienceNetwork

class ShoutsCollectionViewCell: UICollectionViewCell {
    
    enum Mode {
        case regular
        case expanded
    }
    
    enum Data {
        case ad
        case shout
    }
    
    weak var shoutImage: UIImageView? {
        return imageView
    }
    
    weak var name: UILabel? {
        return userNameLabel
    }
    
    weak var shoutTitle: UILabel? {
        return titleLabel
    }
    
    weak var shoutPrice: UILabel? {
        return priceLabel
    }
    
    weak var shoutType: UILabel? {
        return shoutTypeLabel
    }
    
    weak var shoutSubtitle: UILabel? {
        return subtitleLabel
    }
    
    weak var shoutCountryImage: UIImageView? {
        return shoutCountryFlagImageView
    }
    
    weak var shoutCategoryImage: UIImageView? {
        return shoutCategoryImageView
    }
    
    @IBOutlet weak var shoutBackgroundView: UIView?
    
    weak var shoutPromotionBackground: UIView?
    weak var shoutPromotionLabel: UILabel?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shoutTypeLabel: UILabel!
    @IBOutlet weak var shoutCountryFlagImageView: UIImageView!
    @IBOutlet weak var shoutCategoryImageView: UIImageView!
    @IBOutlet weak var messageIconImageView: UIImageView?
    @IBOutlet weak var bookmarkButton: UIButton?
    @IBOutlet weak var adChoicesView: FBAdChoicesView? {
        didSet {
            adChoicesView?.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet var adIconWidth : NSLayoutConstraint!
    @IBOutlet weak var adIconImage: UIImageView!
    
    var currentMode : ShoutsCollectionViewCell.Mode?
    var data : ShoutsCollectionViewCell.Data?  {
        didSet {
            adjustChoicesView()
        }
    }
    
    var currentConstraints: [NSLayoutConstraint] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderColor = UIColor(shoutitColor: .cellBackgroundGrayColor).cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        
        let (promotionView, promotionLabel) = createPromotionViews()
        
        self.shoutPromotionBackground = promotionView
        self.shoutPromotionLabel = promotionLabel
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        currentMode = .regular
        data = .shout
    }
    
    func hydrateWithDiscoverItem(_ discoverItem: DiscoverItem) {
        titleLabel.text = discoverItem.title
        
        if let imagePath = discoverItem.image, let imageURL = URL(string: imagePath) {
            imageView.sh_setImageWithURL(imageURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            imageView.image = UIImage.backgroundPattern()
        }
        
    }
    
    func bindWithAd(Ad ad: FBNativeAd) {
        self.data = .ad
        commonBindWithAd(Ad: ad)
        userNameLabel.text = NSLocalizedString("Sponsored", comment: "")
    }
    
    func bindWith(Shout shout: Shout) {
        self.data = .shout
        commonBindWithShout(shout)
    }

    func bindWith(DiscoverItem discoverItem: DiscoverItem) {
        self.data = .shout
        
        self.shoutTitle?.text = discoverItem.title
        
        if let imagePath = discoverItem.image, let imageURL = URL(string: imagePath) {
            self.shoutImage?.sh_setImageWithURL(imageURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImage?.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        self.shoutSubtitle?.isHidden = true
        self.shoutPrice?.isHidden = true
        self.name?.isHidden = true
        self.bookmarkButton?.isHidden = true
    }
    
    func adjustChoicesView() {
        if let currentMode = currentMode {
            setupViewForMode(currentMode)
        }
        
        self.setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        
        if let add = self.adChoicesView?.nativeAd {
            add.unregisterView()
            adChoicesView?.nativeAd = nil
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ShoutsCollectionViewLayoutAttributes {
            setupViewForMode(attributes.mode)
            currentMode = attributes.mode
        }
    }
    
    fileprivate func setupViewForMode(_ mode: Mode) {
        guard let _ = shoutType else {
            return
        }
        
        titleLabel.numberOfLines = mode == .regular ? 1 : 2
        shoutSubtitle?.isHidden = mode != .expanded
        shoutTypeLabel.isHidden = (mode != .expanded || data == .ad)
        shoutCountryFlagImageView.isHidden =  (mode != .expanded || data == .ad)
        shoutCategoryImageView.isHidden =  (mode != .expanded || data == .ad)
        messageIconImageView?.isHidden = (mode != .expanded || data == .ad)
        userNameLabel.isHidden = (mode == .expanded && data == .shout)
        shoutTitle?.isHidden = false
        shoutPrice?.isHidden = false
        bookmarkButton?.isHidden = data == .ad
        adChoicesView?.isHidden = data == .shout
        adIconImageView.isHidden = data != .ad
        setupConstraintsForMode(mode)
    }
    
    fileprivate func setupConstraintsForMode(_ mode: Mode) {
        
        let views: [String : AnyObject] = ["img" : imageView,
                                           "adIcon" : adIconImage,
                                           "title" : titleLabel,
                                           "usr" : userNameLabel,
                                           "sub" : subtitleLabel,
                                           "price" : priceLabel,
                                           "type" : shoutTypeLabel,
                                           "choices" : adChoicesView!,
                                           "flag" : shoutCountryFlagImageView,
                                           "category" : shoutCategoryImageView,
                                           "msg" : messageIconImageView!]
        
        currentConstraints.forEach { (constraint) in
            constraint.isActive = false
        }
        currentConstraints = []
        
        switch mode {
        case .regular:
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[img]|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[img]-43-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[title]-(>=5)-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[usr]-(>=5)-[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 5)]
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[usr]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[img]-10-[adIcon(0)]", options: [], metrics: nil, views: views)
        case .expanded:
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[img]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[title(20)]-(-7)-[usr(20)]-10-[sub]", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: shoutTypeLabel, attribute: .centerY, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerY, multiplier: 1, constant: 0)]
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[sub]-(>=20)-[type]-10-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: adIconImageView, attribute: .leading, multiplier: 1.0, constant: 10)]
            currentConstraints += [NSLayoutConstraint(item: userNameLabel, attribute: .leading, relatedBy: .equal, toItem: adIconImageView, attribute: .trailing, multiplier: 1.0, constant: 10)]
            
            if data == .ad {
                currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[img(100)]-10-[adIcon(24)]-10-[title]-5-|", options: [], metrics: nil, views: views)
                currentConstraints += [NSLayoutConstraint(item: priceLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 50)]
            } else {
                currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[img(100)]-10-[adIcon(0)]-0-[title]-5-|", options: [], metrics: nil, views: views)
                currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[price]-5-|", options: [], metrics: nil, views: views)
            }
            
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[flag(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[category(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[msg(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[flag(21)]-21-[category(21)]-21-[msg(21)]", options: [], metrics: nil, views: views)
        }
    
        currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[choices(80)]|", options: [], metrics: nil, views: views)
        currentConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[choices(16)]", options: [], metrics: nil, views: views)
        
        currentConstraints.forEach { (constraint) in
            constraint.isActive = true
        }
        
        
    }
}
