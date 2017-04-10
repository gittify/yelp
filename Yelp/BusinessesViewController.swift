//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FiltersViewControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating {
  

    
    var businesses: [Business]!
    var filteredData: [Business]!
   // @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var dealFilterOn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
      //  searchBar.delegate = self
        filteredData = businesses
        tableView.rowHeight=UITableViewAutomaticDimension
        tableView.estimatedRowHeight=120
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        //tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView=searchController.searchBar
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        
        
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredData = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                                   }
            }
            }
        )}

    
    
    func applyFilters() {
        if let dealFromFilter = filterOptions["Offering a Deal"] {
            self.dealFilterOn = dealFromFilter
        }
    }

        func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
            let categories = filters["categories"] as? [String]
            
            Business.searchWithTerm(term: "Restaurants", sort: nil, categories: nil, deals: dealFilterOn) {
                (businesses: [Business]?, error: Error?) -> Void in
                
                self.businesses = businesses
                self.filteredData = businesses
                self.tableView.reloadData()
            }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       /* if businesses != nil {
            return businesses!.count
        }*/
        if filteredData != nil {
            return filteredData!.count
        }
        else {
            return 0
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? businesses : businesses.filter { (item: Business) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return (item.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil) ||
                (item.categories?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil)
        }
        
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = filteredData[indexPath.row]
       // cell.business = businesses[indexPath.row]
        return cell
    
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
        
    }

    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredData = searchText.isEmpty ? businesses : businesses.filter ({ (item: Business) -> Bool in
                // If dataItem matches the searchText, return true to include it
                return (item.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil) ||
                    (item.categories?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil)
                }
            )
            tableView.reloadData()
        }
        
    }
}

