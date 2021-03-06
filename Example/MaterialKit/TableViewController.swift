//
//  TableViewController.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/16/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var labels = ["MKButton", "MKTextField", "MKTableViewCell", "MKTextView", "MKColor", "MKLayer", "MKAlert", "MKCheckBox"]
    var circleColors = [UIColor.MKColor.Blue.P500, UIColor.MKColor.Grey.P500, UIColor.MKColor.Green.P500]

    var refreshView: MKRefreshControl?

    override func viewDidLoad() {
        refreshView = MKRefreshControl()
        refreshView!.addToScrollView(scrollView: self.tableView, withRefreshBlock: { () -> Void in
            self.tableViewRefresh()
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! MyCell
        cell.setMessage(message: labels[indexPath.row % labels.count])
        
        let index = indexPath.row % circleColors.count
        cell.rippleLayerColor = circleColors[index]
        
        return cell
    }

    func tableViewRefresh() {
        NSLog("Refresh Block")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshView!.endRefreshing()
        }
    }
}
