//
//  SHLocationMediaItem.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class SHLocationMediaItem: JSQMediaItem{
    var location: CLLocation?
    var coordinate: CLLocationCoordinate2D?
    var cachedMapSnapshotImage: UIImage?
    var cachedMapImageView: UIImageView?
    
    //pragma mark - Setters
//    func setLocation (location: CLLocation) {
//        self.setLocation(location, withCompletionHandler: nil)
//    }
//    func setAppliesMediaViewMaskAsOutgoing (appliesMediaViewMaskAsOutgoing: Bool) {
//        
//        super.appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing
//        cachedMapImageView = nil
//        cachedMapSnapshotImage = nil
//    }
    
    //pragma mark - Map snapshot
    func setLocation(location: CLLocation, withCompletionHandler: JSQLocationMediaItemCompletionBlock) {
        
        self.setLocation(location, region: MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0), withCompletionHandler: withCompletionHandler)
    }
    
    func setLocation(location: CLLocation, region: MKCoordinateRegion, withCompletionHandler: JSQLocationMediaItemCompletionBlock) {
        
        self.location = location
        self.cachedMapImageView = nil
        self.cachedMapSnapshotImage = nil
        if(self.location == nil) {
            return
        }
        self.createMapViewSnapshotForLocation(location, region: region, withCompletionHandler: withCompletionHandler)
    }
    
    func createMapViewSnapshotForLocation(location: CLLocation, region: MKCoordinateRegion, withCompletionHandler: JSQLocationMediaItemCompletionBlock) {
        
        let options = MKMapSnapshotOptions()
        options.region = region
        options.size = self.mediaViewDisplaySize()
        options.scale = UIScreen.mainScreen().scale
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.startWithQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { (snapShot, error) -> Void in
            if(error != nil) {
                log.error("Error creating map snapshot: \(error?.localizedDescription)")
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                if let image = snapShot?.image, let pinImage = pin.image, let coordinatePoint = snapShot?.pointForCoordinate(location.coordinate) {
                    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                    image.drawAtPoint(CGPointZero)
                    let point = CGPointMake(coordinatePoint.x - pinImage.size.width / 3, coordinatePoint.y - pinImage.size.height)
                    pin.image?.drawAtPoint(point)
                    self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    withCompletionHandler()
                }
                
            })
        }
    }
    
    // pragma mark - MKAnnotation
//    func coordinate() -> CLLocationCoordinate2D {
//        return self.location.coordinate
//    }
    
    //pragma mark - JSQMessageMediaData protocol
    override func mediaView() -> UIView! {
        if(self.location == nil || self.cachedMapSnapshotImage == nil) {
            return nil
        }
        if(self.cachedMapImageView == nil) {
            let imageView = UIImageView(image: self.cachedMapSnapshotImage)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedMapImageView = imageView
        }
        return self.cachedMapImageView
    }
    
    //#pragma mark - NSObject
//    func isEqual(object: AnyObject) -> Bool {
//        if !super.isEqual(object) {
//            return false
//        }
//        var locationItem: JSQLocationMediaItem = object
//        return self.location.isEqual(locationItem.location)
//    }
    
    
    

    
}
