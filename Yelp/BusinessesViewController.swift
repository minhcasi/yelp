//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , FiltersViewControllerDelegate , UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var businesses: [Business]!
    
    var categories : [String]!
    var filters = [String : AnyObject]()
    var keyword : String!
    
    var isSearchMode : Bool!
    let meterValue = 1609.344 as Float
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        
        searchBar.delegate = self
        
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
}


extension BusinessesViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
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
        let offset = 0
        
        Business.searchWithTerm(
            self.keyword,
            sort: sortValue!,
            categories: self.categories,
            deals: deal,
            radius: radiusValue,
            offset: offset
            ) { (response: Response!, error: NSError!) -> Void in
                
                if response != nil {
                    self.businesses = response.businesses
                    self.tableView.reloadData()
                }
            }
    }
}

//["deals_filter": 1, "offset": 0, "radius_filter": 482.8032, "term": , "category_filter": afghani,tradamerican,african,newamerican,arabian, "ll": 37.785771,-122.406165, "sort": 2]

// ["term": , "deals_filter": 0, "offset": 0, "category_filter": asianfusion,burgers, "ll": 37.785771,-122.406165, "sort": 0]
