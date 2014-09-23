//
//  ViewController.swift
//  ios_yelp
//
//  Created by Faith Cox on 9/19/14.
//  Copyright (c) 2014 Yahoo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterDelegate {
    @IBOutlet weak var searchField: UITextField!
    
    
    var client: YelpClient!
    @IBOutlet weak var tableView: UITableView!
    
    var restros: [NSDictionary] = []
    var centerLoc: CLLocation?
    var popFilter: String = "0"
    
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
    let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
    let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
    let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 94
        
        // Do any additional setup after loading the view, typically from a nib.
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        self.searchRestro([
            "term": "Thai",
            "location": "San Francisco"
            ])
        
        /*
        client.searchWithTerm("Thai", success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            
            var jsonData: NSData! = NSJSONSerialization.dataWithJSONObject(response, options: NSJSONWritingOptions(0), error: nil)
            var object = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil) as NSDictionary
            
            self.restros = object["businesses"] as [NSDictionary]
            var regionInfo = object["region"] as AnyObject! as NSDictionary
            var center = regionInfo["center"] as NSDictionary
            var fromLat = center["latitude"] as Double
            var fromLong = center["longitude"] as Double
            self.centerLoc = CLLocation(latitude: fromLat, longitude: fromLong)
            
            self.tableView.reloadData()
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    */
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restros.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //println("I'm at row: \(indexPath.row), section: \(indexPath.section)")
        
        var cell = tableView.dequeueReusableCellWithIdentifier("RestroCell") as RestroCell
        
        var restro = restros[indexPath.row]
        
        cell.restronameLabel.text = restro["name"] as? String
        
        var location = restro["location"] as NSDictionary
        
        var ratingimgUrl = restro["rating_img_url_small"] as String
        cell.ratingView.setImageWithURL(NSURL(string: ratingimgUrl))
        
        cell.ratingLabel.text = String(restro["review_count"] as Int) + " Reviews"
        
        var addy = location["address"] as [String]
        var city = location["city"] as String
        cell.addyLabel.text = "\(addy[0]), \(city)"
        
        //var restroCoordinate = location["coordinate"] as NSDictionary
        if let restroCoordinate = location["coordinate"] as? NSDictionary {
            var restroLat = restroCoordinate["latitude"] as Double
            var restroLong = restroCoordinate["longitude"] as Double
            var restroLoc = CLLocation(latitude: restroLat, longitude: restroLong)
            
            var distInfo = self.centerLoc!.distanceFromLocation(restroLoc)
            cell.distanceLabel.text = String(format: "%.2f mi", distInfo / 1609.34)
            cell.distanceLabel.hidden = false
        } else {
            cell.distanceLabel.hidden = true
        }
        
        cell.priceLabel.hidden = true
        
        var imageUrl = restro["image_url"] as String
        cell.restroView.setImageWithURL(NSURL(string: imageUrl))
        
        var restroCats = restro["categories"] as [[String]]
        var categoryList: String = ""
        
        for category in restroCats
        {
            if (categoryList != "") {
                categoryList += ", "
            }
            categoryList += category[0]
        }
        
        cell.typeLabel.text = categoryList
        
        
        //  var cell = UITableViewCell()
        //    cell.textLabel!.text = "Hello, I'm at row: \(indexPath.row), section: \(indexPath.section)"
        
        return cell
        
    }
    
    @IBAction func searchClick(sender: UIBarButtonItem) {
        
        var term = self.searchField.text as String
        
        if (term != "") {
            self.searchRestro([
                "term": term,
                "location": "San Francisco",
                "deals_filter": self.popFilter
                ])
        } else {
            self.searchRestro([
                "location": "San Francisco",
                "deals_filter": self.popFilter
            ])
        }
    }
    
    func searchRestro (param: [String : String]) {
        
        client.searchWithTerm(param, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            
            var jsonData: NSData! = NSJSONSerialization.dataWithJSONObject(response, options: NSJSONWritingOptions(0), error: nil)
            var object = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil) as NSDictionary
            
            self.restros = object["businesses"] as [NSDictionary]
            var regionInfo = object["region"] as AnyObject! as NSDictionary
            var center = regionInfo["center"] as NSDictionary
            var fromLat = center["latitude"] as Double
            var fromLong = center["longitude"] as Double
            self.centerLoc = CLLocation(latitude: fromLat, longitude: fromLong)
            
            self.tableView.reloadData()
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }

    }
    
    func filtersUpdated(filterViewController: FilterViewController) {
        let openFilter = filterViewController.switchStates[0] != nil && filterViewController.switchStates[0]!
        let hotFilter = filterViewController.switchStates[1] != nil && filterViewController.switchStates[1]!
        let dealFilter = filterViewController.switchStates[2] != nil && filterViewController.switchStates[2]!
        let deliveryFilter = filterViewController.switchStates[3] != nil && filterViewController.switchStates[3]!
        
        
        self.popFilter = dealFilter ? "1" : "0"
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "filterSegue") {
            let filterVC:FilterViewController = segue.destinationViewController as FilterViewController
            filterVC.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

