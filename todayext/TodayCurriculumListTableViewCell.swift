//
//  TodayCurriculumListTableViewCell.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/26.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit

class TodayCurriculumListTableViewCell : NoSelectionTableViewCell {
    
    static let BLOCK_COLORS = [
        [245,98,154],[254,141,63],[236,173,7],[161,210,19],
        [18,202,152],[0,171,212],[109,159,244],[159,115,255]
    ]
    
    @IBOutlet weak var dot : UIView!
    
    @IBOutlet weak var className : UILabel!
    
    @IBOutlet weak var classTime : UILabel!
    
    @IBOutlet weak var classPlace : UILabel!
    
    @IBOutlet weak var classCountdown : UILabel!
    
    static func instance(for tableView: UITableView, model: ClassModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCurriculumListTableViewCell") as! TodayCurriculumListTableViewCell
        
        var a = TodayCurriculumListTableViewCell.BLOCK_COLORS[(model.className.utf16.count + model.className.utf8.count * 2) % TodayCurriculumListTableViewCell.BLOCK_COLORS.count]
        cell.dot.layer.backgroundColor = UIColor(
            red: CGFloat(a[0])/255.0,
            green: CGFloat(a[1])/255.0,
            blue: CGFloat(a[2])/255.0,
            alpha: 1.0).cgColor
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10)
        
        cell.className.text = model.className
        cell.classTime.text = model.weekNum + model.getTimePeriod()
        cell.classPlace.text = model.place.replaceAll("(单)", "").replaceAll("(双)", "")
        cell.classCountdown.text = model.weekSummary
        
        return cell
    }
}
