//
//  FilterViewController.swift
//  ios_yelp
//
//  Created by Faith Cox on 9/21/14.
//  Copyright (c) 2014 Yahoo. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func filtersUpdated(filterViewController: FilterViewController)
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var isExpanded: [Int: Bool] = [Int: Bool]()
    var filters: [[String:AnyObject]]!
    
    var delegate:FilterDelegate? = nil
    var selectedStates: Dictionary<Int, Int> = [:]
    var switchStates: Dictionary<Int, Bool> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50

        var date = NSDate()
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        var time = String(components.hour) + ":" + String(components.minute)
    
        filters = [
            /*
            ["section":"Price", "rowCount":1, "viewType":"segment","config":[
                ["label":"$"],
                ["label":"$$"],
                ["label":"$$$"],
                ["label":"$$$$"]
            ]],
            */
            ["section":"Most Popular", "rowCount":4, "viewType":"switch", "config":[
                ["label":"Open Now \(time)"],
                ["label":"Hot & New"],
                ["label":"Offering a Deal"],
                ["label":"Delivery"],
            ]],
            ["section":"Distance", "rowCount":5, "viewType":"select", "config":[
                ["label":"Auto"],
                ["label":"0.3 miles"],
                ["label": "1 miles"],
                ["label": "5 miles"],
                ["label": "20 miles"],
            ]],
            ["section":"Sort By", "rowCount":4, "viewType":"select", "config":[
                ["label":"Best Match"],
                ["label":"Distance"],
                ["label": "Rating"],
                ["label": "Most Reviewed"],

            ]],
            ["section":"General Features", "rowCount":2, "viewType":"select", "config":[
                ["label":"Online Ordering"],
                ["label":"Take-out"],
            ]],
        ]
        
        tableView.reloadData()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var filter = self.filters[section]
        var rowcount = filter["rowCount"] as AnyObject! as Int
        
        if (section > 0) {
            if (isExpanded[section] != nil) {
                if (isExpanded[section]!) {
                    return rowcount
                } else {
                    return 1
                }
            } else {
                return rowcount
            }
        } else {
            return rowcount
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        
        var headerLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 320, height: 20))
        headerLabel.font = UIFont.systemFontOfSize(15)
        
        var filter = self.filters[section]
        var sectionlabel = filter["section"] as AnyObject! as String
        
        headerLabel.text = sectionlabel        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (isExpanded[indexPath.section] != nil) {
            isExpanded[indexPath.section] = !isExpanded[indexPath.section]!
        } else {
            isExpanded[indexPath.section] = false
            var cell = tableView.dequeueReusableCellWithIdentifier("FilterCell") as FilterCell
            
            var filter = self.filters[indexPath.section]
            var viewType = filter["viewType"] as AnyObject! as String
            var config = filter["config"] as AnyObject! as [[String:String]]
            
            cell.nameLabel.text = config[indexPath.row]["label"] as String!
            println(cell.nameLabel.text )
            
        }
        
        selectedStates[indexPath.section] = indexPath.row
        
        if (tableView.indexPathForSelectedRow() != nil) {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
        }
        
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("FilterCell") as FilterCell
        
        var filter = self.filters[indexPath.section]
        var viewType = filter["viewType"] as AnyObject! as String
        var config = filter["config"] as AnyObject! as [[String:String]]
        
        switch viewType {
            /*
            case "segment":
            self.renderSegmented(cell, config: config, index: row)
            */
        case "switch":
            self.renderSwitch(cell, config: config, cellindexPath: indexPath)
        default:
            cell.nameLabel.text = "Row: \(indexPath.row), Section: \(indexPath.section)"
        }
        cell.nameLabel.text = config[indexPath.row]["label"] as String!
        
        println(cell.nameLabel.text)
        
        return cell
    }

    func renderSegmented(cell: FilterCell, config: [[String:String]], index: Int) -> Void {
        var items : [String] = [String]()
        for item in config {
            items.append(item["label"]!)
        }
        var segmented = UISegmentedControl(items: items)
        segmented.frame = CGRect(x: 10, y: 5, width: 300, height: 40)
        segmented.tintColor = UIColor.lightGrayColor()
        cell.addSubview(segmented)
    }
    
    func renderSwitch(cell: FilterCell, config: [[String:String]], cellindexPath: NSIndexPath) -> Void {
        let itemSwitch = UISwitch(frame: CGRectZero)
        itemSwitch.tag = cellindexPath.section * 100 + cellindexPath.row
        itemSwitch.addTarget(self, action: "onSwitch:", forControlEvents: UIControlEvents.ValueChanged)
        cell.accessoryView = itemSwitch
    }
    
    func renderSelect (cell: FilterCell, config: [[String:String]], cellindexPath: NSIndexPath) -> Void {
        if (cellindexPath.row == 0) {
            cell.setSelected(true, animated: true)
            selectedStates[cellindexPath.section] = cellindexPath.row
        }
    }
    
    
    @IBAction func onCancelFilter(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func onFilterSet(sender: UIBarButtonItem) {
        
        if (delegate != nil) {
            delegate!.filtersUpdated(self)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onSwitch(sender: UISwitch) {
        println(switchStates)
        if (sender.on) {
            switchStates[sender.tag] = true
        } else {
            switchStates[sender.tag] = false
        }
        println(switchStates)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
