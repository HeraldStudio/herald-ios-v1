//
//  TodayNotiTableViewCell.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/26.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit

class TodayNotiTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet weak var icon : UIImageView!
    
    @IBOutlet weak var content : UILabel!
    
    static func instance(for tableView: UITableView, image: UIImage, content: String) -> TodayNotiTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayNotiTableViewCell") as! TodayNotiTableViewCell
        
        cell.icon.image = image
        cell.content.text = content
        
        return cell
    }
}
