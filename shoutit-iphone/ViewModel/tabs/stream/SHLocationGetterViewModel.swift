//
//  SHLocationGetterViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 09/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import GoogleMaps

class SHLocationGetterViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var viewController: SHLocationGetterViewController
    private var autoCompleteTimer: NSTimer?
    private var subString: String?
    private var localSearchQueries = [GMSAutocompletePrediction]()
    private var pastSearchWords = [String]()
    private var pastSearchResults = [String: AnyObject]()
    typealias LocationSelected = (vc: SHLocationGetterViewController?, selected: SHAddress?, isCurrent: Bool?) -> ()
    
    required init(viewController: SHLocationGetterViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        GMSServices.provideAPIKey(Constants.Google.GOOGLE_API_KEY)
        self.viewController.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.viewController.searchTextField.delegate = self
        self.createFooterViewForTable()
        self.viewController.searchTextField.searchBarStyle = UISearchBarStyle.Prominent
    }
    
    func viewWillAppear() {
        self.viewController.becomeFirstResponder()
        self.localSearchQueries.removeAll()
        self.pastSearchResults.removeAll()
        self.pastSearchWords.removeAll()
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    //pragma mark - Autocomplete SearchBar methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.autoCompleteTimer?.invalidate()
        if let string = self.subString {
            self.searchAutocompleteLocationsWithSubstring(string)
            self.viewController.searchTextField.resignFirstResponder()
            self.viewController.locationTableView.reloadData()
        }
    }
    
    func searchAutocompleteLocationsWithSubstring (subString: String) {
        self.localSearchQueries.removeAll()
        self.viewController.locationTableView.reloadData()
        
        if(!self.pastSearchWords.contains(subString)) {
            self.pastSearchWords.append(subString)
            self.retrieveGooglePlaceInformation(subString, withCompletion: { (result) -> () in
                self.localSearchQueries = result
                self.pastSearchResults["\(self.subString)"] = result
                self.viewController.locationTableView.reloadData()
            })
            
        } else {
            for pastResult in self.pastSearchResults {
                if(pastResult.0 == "\(self.subString)") {
                    self.localSearchQueries.append(pastResult.1 as! GMSAutocompletePrediction)
                    self.viewController.locationTableView.reloadData()
                }
                
            }
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.subString = self.viewController.searchTextField.text
        self.subString = self.subString?.stringByReplacingOccurrencesOfString(" ", withString: "+")
        if let string = self.subString {
            if(string.hasPrefix("+") && (string.characters.count > 1)) {
                self.subString = string.substringFromIndex(string.startIndex.advancedBy(1))
            }
        }
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchWordProtection = self.viewController.searchTextField.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
        if (searchWordProtection?.characters.count != 0) {
            self.runScript()
        } else {
            NSLog("The searcTextField is empty.")
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.viewController.searchTextField.text = ""
        self.localSearchQueries.removeAll()
        self.viewController.locationTableView.reloadData()
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func runScript() {
        self.autoCompleteTimer?.invalidate()
        self.autoCompleteTimer = NSTimer(timeInterval: 0.5, target: self, selector: "searchAutocompleteLocationsWithSubstring:", userInfo: nil, repeats: false)
    }
    
    
    // #pragma mark - Google API Requests
    func retrieveGooglePlaceInformation (searchWord: String, withCompletion: [GMSAutocompletePrediction] -> () ) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.City
        GMSPlacesClient.sharedClient().autocompleteQuery(searchWord, bounds: nil, filter: filter) { (results, error) -> Void in
            withCompletion([GMSAutocompletePrediction]())
            if error != nil, let placesResults = results as? [GMSAutocompletePrediction] {
                withCompletion(placesResults)
            }
        }
    }

    func retrieveJSONDetailsAbout(place: String, withCompletion: (address: SHAddress?, error: NSError?) -> ()) {
        GMSPlacesClient.sharedClient().lookUpPlaceID(place) { (place, error) -> Void in
            if let error = error {
                withCompletion(address: nil, error: error)
                return
            }
            if let place = place {
                SHApiMiscService().geocodeLocation(place.coordinate, completionHandler: { (response) -> Void in
                    switch (response.result) {
                    case .Success(let result):
                        withCompletion(address: result, error: nil)
                    case .Failure(let error):
                        withCompletion(address: nil, error: error)
                    
                    }
                    
                })
            }
        }
    }

    // tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.LocationSearchCell, forIndexPath: indexPath) as! SHLocationGetterViewCell
        cell.frame.size.height = 40
        
        switch (indexPath.section) {
            case Enums.LocationSections.TableViewSectionMain.rawValue:
                if(indexPath.row == 0) {
                    if let address = SHAddress.getUserOrDeviceLocation() {
                        cell.textLabel?.text = String(format: "%@ %@ - Current Location", arguments: [address.city, address.country])
                        cell.imageView?.image = UIImage(named: "cellCurrentLocation")
                        return cell
                    }
                }
                let searchResult: GMSAutocompletePrediction = self.localSearchQueries[indexPath.row - 1]
                cell.textLabel?.attributedText = searchResult.attributedFullText
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case Enums.LocationSections.TableViewSectionMain.rawValue:
            if (indexPath.row == 0) {
               // if let address = SHAddress.getUserOrDeviceLocation() {
                   // self.locationSelected(vc: self.viewController, selected: address, isCurrent: true)
                    self.viewController.navigationController?.popViewControllerAnimated(true)
               // }
            }
            let searchResult: GMSAutocompletePrediction = self.localSearchQueries[indexPath.row - 1]
            let placeID = searchResult.placeID
            self.viewController.searchTextField.resignFirstResponder()
            self.retrieveJSONDetailsAbout(placeID, withCompletion: { (address, error) -> () in
               // if let currentAddress = address {
                   // self.locationSelected(vc: self.viewController, selected: currentAddress, isCurrent: false)
                    self.viewController.navigationController?.popViewControllerAnimated(true)
                // }
            })
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case Enums.LocationSections.TableViewSectionMain.rawValue:
            return self.localSearchQueries.count + 1
            default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Enums.LocationSections.TableViewSectionCount.rawValue
    }
    
    func createFooterViewForTable () {
        let footView: UIView = UIView(frame: CGRectMake(0, 500, self.viewController.view.frame.size.width, 70))
        let imageView: UIImageView = UIImageView(image: UIImage(named: "powered-by-google-on-white"))
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        imageView.frame = CGRectMake((self.viewController.view.frame.size.width  - 67), 5, 57, 8)
        footView.addSubview(imageView)
        self.viewController.locationTableView.tableFooterView = footView
    }
    
}
