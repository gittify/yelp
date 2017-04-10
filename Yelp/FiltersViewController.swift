//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Doshi, Nehal on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate{
    @objc optional func filtersViewController (filtersViewController: FiltersViewController,
                                         didUpdateFilters filters: [String:AnyObject])
}

//These are filters needs to be stored globally
var filterOptions = Dictionary<String, Bool>()
var sortBy = 0 // 0 = Best Match, 1 = Distance, 2 = Highest Rated
var radiusFilter = 0 // 0 = auto, 1 = 0.3 miles, 2 = 1 mile, 3 = 5 miles, 4 = 20 miles
var switchStates = [Int:Bool]()
class FiltersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var distanceTableView: ExpandableUITableView!
    @IBOutlet weak var dealsTableView: UITableView!
    @IBOutlet weak var sortableTableView: ExpandableUITableView!
    
    
    var categories: [[String:String]]!
    
    weak var delegate: FiltersViewControllerDelegate!
    
    @IBOutlet weak var distanceHeight: NSLayoutConstraint!
    @IBOutlet weak var sortHeight: NSLayoutConstraint!
  
    let sortByLabels = ["Best Match", "Distance", "Highest Rated"]
    let radiusLabels = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    
    let labelTexts = ["Offering a Deal"]
    
  //  let categories = Categories()
  //  var categoriesData: [Dictionary<String, String>] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  tableView.delegate=self
        dealsTableView.dataSource=self
        tableView.dataSource=self
        sortableTableView.dataSource=self
        distanceTableView.dataSource=self
        
        dealsTableView.delegate=self
        tableView.delegate=self
        sortableTableView.delegate=self
        distanceTableView.delegate=self
        
        categories=yelpCategories()
        tableView.separatorStyle = .none
        dealsTableView.separatorStyle = .none
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    /*func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(tableStructure.count)
        return tableStructure.count
        
    }*/
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       /* print(section)
        print(tableStructure[section].count)
        return  tableStructure[section].count*/
        
        if tableView == self.dealsTableView {
            return labelTexts.count
        } else if tableView == self.distanceTableView {
            return distanceTableView.expanded ? 5 : 1
        } else if tableView == self.sortableTableView {
            return sortableTableView.expanded ? 3 : 1
        }else if tableView == self.tableView{
            return categories.count
        }
        return 0
    }
   
 /*   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tableStructure[section].count)
        return  tableStructure[section].count
    }
 */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print(switchStates)
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            cell.switchLabel.text = categories[indexPath.row]["name"]
            if switchStates[indexPath.row] != nil {
             cell.onSwitch.isOn = switchStates[indexPath.row]!
             }
             else {
             cell.onSwitch.isOn = false
             }
            cell.delegate = self
            return cell
        }else if tableView == self.dealsTableView {
            let cell = dealsTableView.dequeueReusableCell(withIdentifier: "SwCell") as! SwitchCell
            
            let labelText = labelTexts[indexPath.row]
            
            cell.onSwitch.isOn = false
            if let optionOn = filterOptions[labelText] {
                cell.onSwitch.isOn = optionOn
            }
            cell.switchLabel.text = labelText
            cell.delegate = self
            return cell
        }else if tableView == sortableTableView {
            let cell = sortableTableView.dequeueReusableCell(withIdentifier: "ECell") as! ExpandableCell
            
            if sortableTableView.expanded {
                cell.eLabel.text = sortByLabels[indexPath.row]
            } else {
                cell.eLabel.text = sortByLabels[sortBy]
            }
            cell.iconImageView.isHidden = sortableTableView.expanded
            return cell
        } else if tableView == distanceTableView {
            let cell = distanceTableView.dequeueReusableCell(withIdentifier: "ECell") as! ExpandableCell
            if distanceTableView.expanded {
                cell.eLabel.text = radiusLabels[indexPath.row]
            } else {
                cell.eLabel.text = radiusLabels[radiusFilter]
            }
            cell.iconImageView.isHidden = distanceTableView.expanded
            return cell
        }
        // This does not matter
        return dealsTableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        
    }
    
    // MARK: - Navigation

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sortableTableView {
            if sortableTableView.expanded {
                //apply new sort method
                sortBy = indexPath.row
            }
            sortableTableView.expanded = !sortableTableView.expanded
            sortableTableView.reloadData()
            self.sortHeight.constant = self.sortableTableView.contentSize.height
            self.view.layoutIfNeeded()
        } else if tableView == distanceTableView {
            if distanceTableView.expanded {
                //apply new sort method
                radiusFilter = indexPath.row
            }
            distanceTableView.expanded = !distanceTableView.expanded
            distanceTableView.reloadData()
            self.distanceHeight.constant = 144
            self.view.layoutIfNeeded()
        }
    }

    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
         dismiss(animated: true,completion: nil)
        var filters = [String: AnyObject]()
        
        var selectedCategories = [String] ()
        for (row,isSelected) in switchStates{
            if isSelected{
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value:Bool){
      
        print("filters view controller got switch event")
        if (switchCell.switchLabel.text == labelTexts[0])
            {
                setFilterValue(switchCell.switchLabel.text!, value: value)
        }
        else {
            let indexPath = tableView.indexPath(for: switchCell)!
            print("in switch cell delegate method of filtervc")
            switchStates[indexPath.row] = value
            print(indexPath.row)
            print(switchStates)
        }
    }
    
   

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          }

    func yelpCategories() -> [[String:String]] {
        return [["name":"Afghan","code":"afghani"],
            ["name":"American","code":"American"],
            ["name":"African","code":"african"],
            ["name":"Indian","code":"indian"],
            ["name":"Korean","code":"korean"],
            ["name":"Malayasian","code":"malaya"],
            ["name":"Indonesian","code":"indo"],
            ["name":"Isrealian","code":"isreal"],
            ["name":"Argentia","code":"argentina"],
            ["name":"China","code":"china"],
            ["name":"Thai","code":"Thai"]
        
        ]
    }
    
    func setFilterValue(_ name: String, value: Bool) {
        filterOptions[name] = value
    }
    
    func onBoolValueChange(_ value: Bool, labelText: String) {
        print  ("value \(value) \(labelText)")
        setFilterValue(labelText, value: value)
    }
}
