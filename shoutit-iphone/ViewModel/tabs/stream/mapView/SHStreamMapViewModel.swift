//
//  SHStreamMapViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MapKit

class SHStreamMapViewModel: NSObject, MKMapViewDelegate {

    private let viewController: SHStreamMapViewController
    
    required init(viewController: SHStreamMapViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        var coordinate = CLLocationCoordinate2D()
        if let latitude = SHAddress.getUserOrDeviceLocation()?.latitude, longitude = SHAddress.getUserOrDeviceLocation()?.longitude {
            coordinate.latitude = Double(latitude)
            coordinate.longitude = Double(longitude)
        }
        let span = MKCoordinateSpanMake(0.7, 0.7)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.viewController.mapView.setRegion(region, animated: true)
        self.viewController.mapView.setCenterCoordinate(coordinate, animated: true)
    }
    
    func viewDidAppear() {
        self.refreshShouts()
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func refreshShouts () {
        let mapRegion = self.viewController.mapView.region
        let topRightCoordinate = CLLocationCoordinate2DMake(mapRegion.center.latitude + mapRegion.span.latitudeDelta / 2.0, mapRegion.center.longitude + mapRegion.span.longitudeDelta / 2.0)
        let bottomLeftCoordinate = CLLocationCoordinate2DMake(mapRegion.center.latitude - mapRegion.span.latitudeDelta / 2.0, mapRegion.center.longitude - mapRegion.span.longitudeDelta / 2.0)
        self.viewController.apiShout.loadShoutMapWithBottomLeft(bottomLeftCoordinate, up_right: topRightCoordinate, zoom: self.viewController.mapView.zoomLevel(), cacheResponse: { (shShoutMeta) -> Void in
             // Do Nothing
            }) { (response) -> Void in
                // Do Nothing
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation.isKindOfClass(SHShoutAnnotation)) {
            let annotationView = MKAnnotationView()
            let location = SHAddress.getUserOrDeviceLocation()
            annotationView.enabled = true
            annotationView.canShowCallout = false
            
//            SHShout* shout = [((SHShoutAnnotation*)annotation) shout];
//            
//            annotationView.enabled = YES;
//            annotationView.canShowCallout = NO;
//            
//            if([[shout type] isEqualToString:@"Offer"])
//            {
//                [annotationView setImage:[UIImage imageNamed:@"offerMapPin.png"]];
//                annotationView.centerOffset = CGPointMake(10, -21);
//                
//            }else{
//                [annotationView setImage:[UIImage imageNamed:@"requestMapPin.png"]];
//                annotationView.centerOffset = CGPointMake(-10, -21);
//                
//            }
//            
//            
//            annotationView.frame = CGRectMake(0, 0, 41, 43);
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let annotation = view.annotation, let title = annotation.title, let subtitle = annotation.subtitle {
            if (annotation.isKindOfClass(SHShoutAnnotation)) {
                self.viewController.calloutView?.title = title
                self.viewController.calloutView?.subtitle = subtitle
                
            }
        }
        
        
        
//        if([view.annotation isKindOfClass:[SHShoutAnnotation class]])
//        {
//            
//            self.calloutView.title = view.annotation.title;
//            self.calloutView.subtitle = view.annotation.subtitle;
//            self.calloutView.calloutOffset = view.calloutOffset;
//            SHShout* shout = [((SHShoutAnnotation*)view.annotation) shout];
//            SHShoutCalloutView *contentView =[SHShoutCalloutView loadViewFromNib];
//            [contentView setShout:shout withAccessoryBlock:
//                ^(SHShout *shout)
//                {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                SHShoutDetailTableViewController* detailView = [SHNavigator viewControllerFromStoryboard:@"StreamStoryboard" withViewControllerId:@"SHShoutDetailTableViewController"];
//                detailView.title = shout.title;
//                [detailView getDetailShouts:shout];
//                [self.navigationController pushViewController:detailView animated:YES];
//                });
//                
//                }];
//            
//            UIView *superview = [[UIView alloc]initWithFrame:contentView.frame];
//            [superview addSubview:contentView];
//            self.calloutView.contentView = superview;
//            
//            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
//            self.calloutView.constrainedInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
//            
//            [self.calloutView presentCalloutFromRect:view.bounds inView:view constrainedToView:self.mapView animated:YES];
//            NSLog(@"bounds %f %f %f %f", view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width,view.bounds.size.height);
//        }else{
//            NSLog(@"User Annotation");
//            
//        }
    }
    
}
