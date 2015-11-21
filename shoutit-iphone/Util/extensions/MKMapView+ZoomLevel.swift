//
//  MKMapView+ZoomLevel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 18/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    func zoomLevel() -> Double {
        let mapView = MKMapView()
        let MERCATOR_RADIUS = 85445659.44705395
        let MAX_GOOGLE_LEVELS = 20
        let longitudeDelta = mapView.region.span.longitudeDelta
        let mapWidthInPixels = mapView.bounds.size.width
        let zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / Double((100.0 * mapWidthInPixels))
        var zoomer = Double(MAX_GOOGLE_LEVELS) - log2(zoomScale)
        if(zoomer < 0) {
            zoomer = 0
        }
        return zoomer
    }
}