//
//  FiltersViewController.swift
//  Yelp
//
//  Created by minh on 11/17/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit


@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, DropdownCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let data = NSUserDefaults.standardUserDefaults()
    
    var categories: [[String: String]] = []
    var switchStates = [Int: Bool]()
    var delegate: FiltersViewControllerDelegate?
    var radius: [Float?]!
    var sortBy: [String?]!
    
    var filters = [String : AnyObject]()
    
    var isCollapseDistance = true
    var isCollapseSortBy = true
    var isCollapseCategories = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = Common.yelpCategory()
        tableView.delegate = self
        tableView.dataSource = self
        
        radius = [nil, 0.3, 1, 5, 20]
        sortBy = ["Best Match", "Distance", "Rating"]
        
        getSavedFilter()
        
        // Do any additional setup after loading the view.
    }
    
    // get from saved data for filter
    func getSavedFilter() {
        let switchStatesData = data.objectForKey("switchStates") as? NSData
        if (switchStatesData != nil) {
            switchStates = NSKeyedUnarchiver.unarchiveObjectWithData(switchStatesData!) as! [Int:Bool]
        }
        
        let filtersData = data.objectForKey("filters") as? NSData
        if (filtersData != nil) {
            filters = NSKeyedUnarchiver.unarchiveObjectWithData(filtersData!) as! [String : AnyObject]
        }
        else {
            filters["deal"] = false
            filters["radius"] = radius[0]
            filters["sortBy"] = sortBy[0]
        }
    }
    
    // save filters to NSUserDefaults
    func saveFilter() {
        let switchStatesData = NSKeyedArchiver.archivedDataWithRootObject(switchStates)
        self.data.setObject(switchStatesData, forKey: "switchStates")

        let filtersData = NSKeyedArchiver.archivedDataWithRootObject(filters)
        data.setObject(filtersData, forKey: "filters")
        data.synchronize()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    
    @IBAction func onSearch(sender: AnyObject) {
        dismissViewControllerAnimated(true , completion: nil)
        var selectedCategories = [String]()
        
        for(row, isSelected) in switchStates    {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if (selectedCategories.count > 0)   {
            filters["categories"] = selectedCategories
        }
        
        delegate!.filtersViewController!(self, didUpdateFilters: filters)
        
        saveFilter()
    }
    
    // implement for switchCellDelegate
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        if indexPath.section == 0 {
            self.filters["deal"] = value
        } else  {
            switchStates[indexPath.row] = value
        }
    }
    
}


// impelemnt tableview function
extension FiltersViewController {
    // populate cell data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return getCellDeal(indexPath)
        case 1:
            return getCellDistance(indexPath)
        case 2:
            return getCellSortBy(indexPath)
        case 3:
            return getCellCategories(indexPath)
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    // get height for row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            if isCollapseDistance {
                let radiusValue = filters["radius"] as! Float?
                if radiusValue != radius[indexPath.row] {
                    return 0
                }
            }
            break
        case 2:
            if isCollapseSortBy {
                let sortValue = String(filters["sortBy"]!)
                if sortValue != sortBy[indexPath.row] {
                    return 0
                }
            }
            break
        case 3:
            // show limit to 5 categories when it is collapse
            if isCollapseCategories && indexPath.row > 4 && indexPath.row != categories.count {
                return 0
            }
            break
        default:
            break
        }
        
        return 60
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // table header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
      
        
        switch section {
        case 0:
            cell.titleLabel.text = "DEAL"
            break
        case 1:
            cell.titleLabel.text = "DISTANCE"
            break
        case 2:
            cell.titleLabel.text = "SORT BY"
            break
        case 3:
            cell.titleLabel.text = "CATEGORIES"
            break
        default:
            return nil
        }
        return cell.headerView
    }
    
    
    // table header height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // number row on section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return radius.count
        case 2:
            return sortBy.count
        case 3:
            return categories.count + 1
        default:
            break
        }
        
        return 0
    }
    
    // number of section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
}

extension FiltersViewController {
    func getCellDeal(indexPath : NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        
        cell.switchLabel.text = "Offering a Deal"
        cell.delegate = self
        
        cell.onSwitch.on = self.filters["deal"]! as? Bool ?? false
        return cell
    }
    func getCellDistance(indexPath : NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! DropdownCell
        cell.delegate = self
        
        // Set label for each cell
        if indexPath.row == 0 {
            cell.titleLabel.text = "Auto"
        }
        
        if indexPath.row > 0 {
            if self.radius[indexPath.row] == 1 {
                cell.titleLabel.text =  String(format: "%g", self.radius[indexPath.row]!) + " mile"
            } else {
                cell.titleLabel.text =  String(format: "%g", self.radius[indexPath.row]!) + " miles"
            }
        }
        
        let radiusValue = filters["radius"] as! Float?
        let isChecked = radiusValue == self.radius[indexPath.row]
        
        cell.setIconImage(isCollapseDistance, isChecked: isChecked)
        
        return cell
    }
    func getCellSortBy(indexPath : NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! DropdownCell
        cell.delegate = self
        
        if  0 ... 2 ~= indexPath.row    {
            cell.titleLabel.text = self.sortBy[indexPath.row]
        }
        
        
        let sortByValue = filters["sortBy"] as! String?
        let isChecked = sortByValue == self.sortBy[indexPath.row]

        cell.setIconImage(isCollapseSortBy, isChecked: isChecked)
        return cell
    }
    func getCellCategories(indexPath : NSIndexPath) -> UITableViewCell{
        
        if indexPath.row != categories.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            
            cell.onSwitch.on = switchStates[indexPath.row] ?? false
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ViewAllCell", forIndexPath: indexPath) as! ViewAllCell
            let tapToViewAll = UITapGestureRecognizer(target: self, action: "viewAllCategory:")
            cell.addGestureRecognizer(tapToViewAll)
            
            return cell
        }
    }
    
    // show all categories
    func viewAllCategory(sender:UITapGestureRecognizer) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: categories.count, inSection: 3)) as! ViewAllCell
        
        if cell.titleLabel.text == "View all" {
            cell.titleLabel.text = "Collapse"
            isCollapseCategories = false
        } else {
            cell.titleLabel.text = "See All"
            isCollapseCategories = true
        }
        tableView.reloadData()
    }
    
    // implement the dropdownCelldelegate
    func dropdownCell(dropdownCell: DropdownCell, didChangeValue iconImage: UIImage) {
        let indexPath = tableView.indexPathForCell(dropdownCell)
        
        if indexPath != nil {
            // if is distance radius section
            if indexPath!.section == 1 {
                switch iconImage {
                case UIImage(named: DropdownCell.ICON_ARROW)!:
                    isCollapseDistance = false
                    break
                case UIImage(named: DropdownCell.ICON_CHECKED)!:
                    isCollapseDistance = true
                    break
                case UIImage(named: DropdownCell.ICON_UNCHECK)!:
                    filters["radius"] = radius[indexPath!.row]
                    isCollapseDistance = true
                    break
                default:
                    break
                }
            } else if indexPath!.section == 2 {
                // if is sort by section
                switch iconImage {
                case UIImage(named: DropdownCell.ICON_ARROW)!:
                    isCollapseSortBy = false
                    break
                case UIImage(named: DropdownCell.ICON_CHECKED)!:
                    isCollapseSortBy = true
                    break
                case UIImage(named: DropdownCell.ICON_UNCHECK)!:
                    filters["sortBy"] = sortBy[indexPath!.row]
                    isCollapseSortBy = true
                    break
                default:
                    break
                }
            }
            
            tableView.reloadData()
        }
    }
}
