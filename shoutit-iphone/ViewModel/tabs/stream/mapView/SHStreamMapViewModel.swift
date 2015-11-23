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
    private var shouts: [SHShout] = []
    
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
                switch(response.result) {
                case .Success(let result):
                    self.shouts = result.results
                    var annotations: [SHShoutAnnotation] = []
                    for shout in self.shouts {
                        if let lat = shout.location?.latitude, let lon = shout.location?.longitude {
                            annotations.append(SHShoutAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lon)), shout: shout))
                        }
                    }
                    self.viewController.mapView.removeAnnotations(self.viewController.mapView.annotations)
                    self.viewController.mapView.addAnnotations(annotations)
                case .Failure(let error):
                    log.error("error getting shouts : \(error.localizedDescription)")
                }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation.isKindOfClass(SHShoutAnnotation.classForCoder())) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("SHShoutAnnotationView")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "SHShoutAnnotationView")
            }
            
            annotationView!.enabled = true
            annotationView!.canShowCallout = false
            
            if let shout = (annotation as? SHShoutAnnotation)?.shout {
                if shout.type == .Offer {
                    annotationView!.image = UIImage(named: "offerMapPin")
                    annotationView!.centerOffset = CGPointMake(10, -21)
                } else {
                    annotationView!.image = UIImage(named: "requestMapPin")
                    annotationView!.centerOffset = CGPointMake(-10, -21)
                }
            }
            annotationView!.frame = CGRectMake(0, 0, 41, 43)
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation {
            if (annotation.isKindOfClass(SHShoutAnnotation)) {
                if let annotationTitle = view.annotation?.title {
                    self.viewController.calloutView?.title = annotationTitle
                }
                if let annotationSubTitle = view.annotation?.subtitle {
                    self.viewController.calloutView?.subtitle = annotationSubTitle
                }
                self.viewController.calloutView?.calloutOffset = view.calloutOffset
                
                if let shout = (view.annotation as? SHShoutAnnotation)?.shout {
                    let contentView = SHShoutCalloutView.loadViewFromNib()
                    
                    contentView.setShout(shout, withAccessoryBlock: { (shout) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // TODO
//                            SHShoutDetailTableViewController* detailView = [SHNavigator viewControllerFromStoryboard:@"StreamStoryboard" withViewControllerId:@"SHShoutDetailTableViewController"];
//                            detailView.title = shout.title;
//                            [detailView getDetailShouts:shout];
//                            [self.navigationController pushViewController:detailView animated:YES];
                        })
                    })
                    let superView = UIView(frame: contentView.frame)
                    superView.addSubview(contentView)
                    
                    self.viewController.calloutView?.contentView = superView
                    
                    self.viewController.calloutView?.constrainedInsets = UIEdgeInsetsMake(self.viewController.topLayoutGuide.length, 0, self.viewController.bottomLayoutGuide.length, 0)
                    
                    self.viewController.calloutView?.presentCalloutFromRect(view.bounds, inView: view, constrainedToView: self.viewController.mapView, animated: true)
                }
            }
        }
    }
    
}
