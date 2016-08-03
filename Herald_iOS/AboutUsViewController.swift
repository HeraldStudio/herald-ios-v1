//
//  AboutUsViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class AboutUsViewController : UITableViewController {
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 64;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCellWithIdentifier("AboutUsLogoTableViewCell")!
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("AboutUsContentTableViewCell") as! AboutUsContentTableViewCell
            cell.title.text = ["关于我们", "联系我们", "法律声明"][indexPath.row - 1]
            cell.content.text = [StringAboutUs, StringContactUs, StringTerms][indexPath.row - 1]
            return cell
        }
    }
}