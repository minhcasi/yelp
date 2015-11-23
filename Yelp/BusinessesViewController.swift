//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , FiltersViewControllerDelegate , UISearchBarDelegate  {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cMapView: MKMapView!
    
    
    let locationMng = CLLocationManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var businesses = [Business]()
    
    var categories : [String]!
    var filters = [String : AnyObject]()
    var keyword : String!
    
    var totalResult = 0
    var isSearchMode : Bool!
    let meterValue = 1609.344 as Float
    
    @IBOutlet weak var changeModeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        
        searchBar.delegate = self
        cMapView.hidden = true
        
        getFiltersData()
        doSearching()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    
    // update table list after updated filter
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        self.filters = filters
        doSearching()
    }
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearchMode = false
            
        }
        else {
            isSearchMode = true
            self.keyword = searchBar.text!.lowercaseString
            doSearching()
        }
    }
    
    
    @IBAction func changeModeView(sender: AnyObject) {
        if (changeModeButton.image == UIImage(named: "map-view"))   {
            // show list view
            tableView.hidden = true
            cMapView.hidden = false
            changeModeButton.image = UIImage(named: "list-view")
        }
        else {
            // show map view
            tableView.hidden = false
            cMapView.hidden = true
            changeModeButton.image = UIImage(named: "map-view")
        }
    }
    
    
    func createMarkers() {
//        if businesses.count > 0 {
//            MKMapCamera.lati
//            
//            var camera = GMSCameraPosition.cameraWithLatitude(businesses[0].latitude!, longitude: businesses[0].longitude!, zoom: 15)
//            mapView.camera = camera
//            mapView.myLocationEnabled = true
//            
//            // Create maker for each business
//            for i in 0..<businesses!.count {
//                var marker = GMSMarker()
//                marker.position = CLLocationCoordinate2DMake(businesses[i].latitude!, businesses[i].longitude!)
//                marker.icon = createMarkerIcon(i + 1)
//                marker.map = mapView
//            }
//        }
    }

}


extension BusinessesViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        
        if businesses.count < totalResult {
            if indexPath.row == self.businesses.count - 1 {
                doSearching()
            }
        }
        
        return cell
    }
    
    func getFiltersData() {
        // init as default
        let data = NSUserDefaults.standardUserDefaults()
        let filtersData = data.objectForKey("filters") as? NSData
        if (filtersData != nil) {
            filters = NSKeyedUnarchiver.unarchiveObjectWithData(filtersData!) as! [String : AnyObject]
        }
        else {
            filters["deal"] = false
            filters["radius"] = nil
            filters["sortBy"] = "Best Match"
            filters["categories"] = ["asianfusion" , "burgers"]
        }
        
        self.keyword = ""

    }
    
    // do searching
    func doSearching() {
        self.categories = filters["categories"] as? [String]
        let sortModeMapping : [String:YelpSortMode] = [
            "Best Match" : YelpSortMode.BestMatched,
            "Distance" : YelpSortMode.Distance,
            "Rating" : YelpSortMode.HighestRated
        ]
        let sortValue = sortModeMapping[(filters["sortBy"] as? String)!]
        let deal = filters["deal"] as? Bool
        let radius = filters["radius"] as! Float?
        var radiusValue = radius
        if radius != nil {
            radiusValue = radius! * meterValue
        }
        
        let offset = self.businesses.count

        
        Business.searchWithTerm(
            self.keyword,
            sort: sortValue!,
            categories: self.categories,
            deals: deal,
            radius: radiusValue,
            offset: offset
            ) { (response: Response!, error: NSError!) -> Void in
                
                if response != nil {
                    self.totalResult = response.total!
                    if offset < response.total {
                        for business in response.businesses {
                            self.businesses.append(business)
                        }
                    }
                    self.tableView.reloadData()
                    self.loadMapView()
                }
            }
    }
    
    func addLocation(latitude: Double, longtitude : Double, title: String) {
        let location = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longtitude
        )
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegion(center: location, span: span)
        
        cMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        cMapView.addAnnotation(annotation)
    }
    
    func loadMapView() {
        self.addLocation(37.785771,longtitude: -122.406165, title: "San Francisco")
        
        
        if businesses.count > 0 {
            for business in businesses {
                self.addLocation(business.latitude!, longtitude: business.longitude!, title: business.name!)
            }
        }
    }
}




