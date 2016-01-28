//
//  SHMapDetatilViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MapKit

class SHMapDetatilViewController: UIViewController, UIActionSheetDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var shout: SHShout?
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(title: NSLocalizedString("Get Direction To Shout", comment: "Get Direction To Shout"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("openMapApp:"))
        let done = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("done:"))
        self.navigationItem.leftBarButtonItem = done
        self.navigationItem.rightBarButtonItem = barButton
        
        var pinCoordinate = CLLocationCoordinate2D()
        if let coordinate = self.location?.coordinate, let shout = self.shout {
            pinCoordinate.latitude = coordinate.latitude
            pinCoordinate.longitude = coordinate.longitude
            let annotation = SHShoutAnnotation(coordinate: pinCoordinate, shout: shout)
            if(self.mapView.annotations.count > 0) {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            self.mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: false)
            self.mapView.setCenterCoordinate(coordinate, animated: true)
            self.mapView.showsUserLocation = true
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func openMapApp (sender: AnyObject) {
        let sheet = UIActionSheet(title: NSLocalizedString("Get Direction", comment: "Get Direction"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: "Apple Maps", "Google Maps")
        if let toolbar = self.navigationController?.toolbar {
            sheet.showFromToolbar(toolbar)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let coordinate = self.location?.coordinate {
            if(buttonIndex == 1) {
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = self.shout?.title
                
                let launchOption = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()
                MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOption)
            } else if (buttonIndex == 2) {
                if let url = NSURL(string: String(format: "comgooglemaps://?saddr=&daddr=%f,%f", arguments: [coordinate.latitude, coordinate.longitude])) {
                    if(!UIApplication.sharedApplication().canOpenURL(url)) {
                        SHProgressHUD.showError(NSLocalizedString("Google Maps app is not installed", comment: "Google Maps app is not installed"), maskType: .Black)
                    } else {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
    }
    
    
    func done(sender : AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func presentFromViewController(parent: UIViewController, location: CLLocation, shout: SHShout?) {
        let vc = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMAPDETAIL) as! SHMapDetatilViewController
        vc.location = location
        vc.shout = shout
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barTintColor = UIColor(shoutitColor: .ShoutGreen)
        navController.navigationBar.tintColor = UIColor.whiteColor()
        navController.setNavigationBarHidden(true, animated: false)
        parent.presentViewController(vc, animated: true, completion: nil)
    }
    

}
