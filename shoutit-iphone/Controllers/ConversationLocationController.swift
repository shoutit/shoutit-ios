//
//  ConversationLocationController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class ConversationLocationController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var coordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(self.coordinates, 1000, 1000), animated: true)
        self.mapView.addAnnotation(Annotation(coordinate: coordinates))
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.viewForAnnotation(annotation)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "locationPin")
        }
        
        annotationView?.image = UIImage(named: "location")
        
        return annotationView
    }
}
