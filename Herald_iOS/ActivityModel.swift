//
//  ActivityModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/11.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActivityModel {
    var title : String
    var intro : String
    var startTime : String
    var endTime : String
    var activityTime : String
    var detailUrl : String
    var picUrl : String
    var assoc : String
    var location : String
    
    init (_ title : String, _ intro : String, _ startTime : String, _ endTime : String, _ activityTime : String, _ detailUrl : String, _ picUrl : String, _ assoc : String, _ location : String) {
        self.title = title
        self.intro = intro
        self.startTime = startTime
        self.endTime = endTime
        self.activityTime = activityTime
        self.detailUrl = detailUrl
        self.picUrl = picUrl
        self.assoc = assoc
        self.location = location
    }
    
    init (_ json : JSON) {
        title = json["title"].stringValue
        intro = json["introduction"].stringValue
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        activityTime = json["activity_time"].stringValue
        detailUrl = json["detail_url"].stringValue
        picUrl = json["pic_url"].stringValue
        assoc = json["association"].stringValue
        location = json["location"].stringValue
    }
    
    enum ActivityState : String {
        case Coming = "即将开始"
        case Going = "进行中"
        case Gone = "已结束"
    }
    
    var start : GCalendar {
        return GCalendar(startTime)
    }
    
    var end : GCalendar {
        return GCalendar(endTime)
    }
    
    var state : ActivityState {
        let now = GCalendar(.Day)
        if now < start {
            return .Coming
        }
        if now <= end {
            return .Going
        }
        if now > end {
            return .Gone
        }
        return .Gone
    }
    
    var time : String {
        if start < end {
            return "\(startTime) ~ \(endTime)"
        }
        return startTime
    }
}