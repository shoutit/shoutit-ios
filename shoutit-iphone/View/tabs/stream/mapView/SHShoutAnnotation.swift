//
//  SHShoutAnnotation.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 18/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MapKit

class SHShoutAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subTitle: String?
    var shout: SHShout?
    
    init(coordinate: CLLocationCoordinate2D, shout: SHShout) {
        self.coordinate = coordinate
        self.shout = shout
        self.title = shout.title
    }
    
    func annotationView () -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "SHShoutAnnotationView")
        annotationView.enabled = true
        annotationView.canShowCallout = true
        let imageView = UIImageView(frame: CGRectMake(0, 0, 32, 32))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        if let thumbnail = self.shout?.thumbnail, let url = NSURL(string: thumbnail) {
            imageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "shoutStarted"), optionsInfo: .None, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if(image == nil) {
                    imageView.image = UIImage(named: "no_image_available")
                }
            })
        }
        let imgMask = UIImage(named: "shoutMask")
        let mask = CALayer()
        mask.contents = imgMask?.CGImage
        mask.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)
        imageView.layer.mask = mask
        imageView.layer.masksToBounds = true
        
        annotationView.leftCalloutAccessoryView = imageView
        annotationView.frame = CGRectMake(0, 0, 50, 50)
        return annotationView
        
    }
   
}
