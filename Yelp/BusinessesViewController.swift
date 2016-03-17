//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var navTitle = "Yelp"
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        if Reachability.isConnectedToNetwork() {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)// show loading state
            loadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)// hide loading state
        } else {
            navigationItem.title = "Disconnected"
        }
        
        

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    @IBAction func search(sender: AnyObject) {
        navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }



    func loadData() {
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.navigationItem.title = self.navTitle
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
        
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            
            for char in searchText.characters {
                if char == " " {
                    continue
                } else {
                    self.navigationItem.title = self.navTitle
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    Business.searchWithTerm(searchText, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                        self.businesses = businesses
                        self.tableView.reloadData()
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        searchBar.endEditing(true)
                        
                    })
                    
                    return
                }
            }
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                searchBar.endEditing(true)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
        navigationItem.titleView = nil
    }
    
    
    internal class Reachability {
        class func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
                SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        if Reachability.isConnectedToNetwork() {
            loadData()
        } else {
            navigationItem.title = "Disconnected"
        }
        refreshControl.endRefreshing()
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
