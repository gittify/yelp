//
//  ExpandableUITableView.swift
//  Yelp
//
//  Created by Doshi, Nehal on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class ExpandableUITableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var expanded = false
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.separatorStyle = .none
        self.rowHeight = 34
    }
}
