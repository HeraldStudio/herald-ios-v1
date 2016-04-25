//
//  JwcNoticeModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class JwcNoticeModel {
    var title : String
    var time : String
    var url : String
    
    init (_ title : String, _ time : String, _ url : String) {
        self.title = title
        self.time = time
        self.url = url
    }
    
    init (json : JSON) {
        let todayComp = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        let today = String(format: "%4d-%02d-%02d", todayComp.year, todayComp.month, todayComp.day)
        let yesterdayComp = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate().dateByAddingTimeInterval(-86400))
        let yesterday = String(format: "%4d-%02d-%02d", yesterdayComp.year, yesterdayComp.month, yesterdayComp.day)
        
        title = json["title"].stringValue
        time = "发布时间：" + json["date"].stringValue.replaceAll(today, "今天").replaceAll(yesterday, "昨天")
        url = json["href"].stringValue
    }
}