//
//  SHStreamMapViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import SMCalloutView
import MapKit

class CustomMapView: MKMapView {
    var calloutView: SMCalloutView?
}

class SHStreamMapViewController: BaseViewController, SMCalloutViewDelegate {
    
    @IBOutlet weak var mapView: CustomMapView!
    private var viewModel: SHStreamMapViewModel?
    private var isInitial = true
    private var array = []
    var apiShout = SHApiShoutService()
    var calloutView: SMCalloutView?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHStreamMapViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let streamB = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("switchToStreamView:"))
        self.navigationItem.rightBarButtonItem = streamB
        self.navigationItem.hidesBackButton = true
        
        //create our custom callout view
        self.calloutView = SMCalloutView.platformCalloutView()
        self.calloutView?.delegate = self
        self.mapView.calloutView = self.calloutView
        self.calloutView?.prepareForInterfaceBuilder()
        self.title = NSLocalizedString("Shout Map", comment: "Shout Map")
        
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchToStreamView(sender: AnyObject) {
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(0.50)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        if let navigation = self.navigationController?.view {
             UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromLeft, forView: navigation, cache: false)
        }
        self.navigationController?.popViewControllerAnimated(true)
        UIView.commitAnimations()
    }
    
    
    
    deinit {
        viewModel?.destroy()
    }
}
