//
//  ExperimentNotifier.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/6.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExperimentModel {
    var name : String
    var timeAndPlace : String
    var teacher : String
    var grade : String
    
    convenience init (json: JSON) {
        let name = json["name"].stringValue
        let date = json["Date"].stringValue
        let day = json["Day"].stringValue
        let place = json["Address"].stringValue
        let teacher = json["Teacher"].stringValue
        
        var grade : String = ""
        if json["Grade"].string != nil {
            grade = json["Grade"].string!
        }
        self.init(name, date + day + " @ " + place, teacher, grade)
    }
    
    init (_ name : String, _ timeAndPlace : String, _ teacher : String, _ grade : String) {
        self.name = name
        self.timeAndPlace = timeAndPlace
        self.teacher = teacher
        self.grade = grade
    }
}

class ExperimentNotifier {
    static func getNotification () -> NotificationModel? {
        
        let cache = CacheHelper.get("herald_experiment")
        let content = JSON.parse(cache)["content"]
        
        for section in content {
            let array = section.1
            if array.count == 0 {
                continue
            }
            
            //如果有实验则加载数据和子项布局
            for jsonObject in array.arrayValue {
                let date = jsonObject["Date"].stringValue
                let ymdStr = date.split("日")[0]
                    .replaceAll("年", "-")
                    .replaceAll("月", "-")
                    .split("-")
                let ymd = [Int(ymdStr[0]), Int(ymdStr[1]), Int(ymdStr[2])]
                guard let year = ymd[0] else { continue }
                guard let month = ymd[1] else { continue }
                guard let day = ymd[2] else { continue }
                
                let now = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .WeekOfYear, .Weekday, .Hour, .Minute], fromDate: NSDate())
                var then = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
                
                (then.year, then.month, then.day) = (year, month, day)
                switch jsonObject["Day"].stringValue {
                case "上午": (then.hour, then.minute) = (9, 45)
                case "下午": (then.hour, then.minute) = (13, 45)
                default: (then.hour, then.minute) = (18, 15)
                }
                
                then = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .WeekOfYear, .Weekday, .Hour, .Minute], fromDate: NSCalendar.currentCalendar().dateFromComponents(then)!)
                let model = ExperimentModel(json: jsonObject)
                
                // 属于同一周
                if then.year == now.year && then.weekOfYear == now.weekOfYear {
                    // 如果发现今天有实验
                    if then.weekday == now.weekday {
                        // 快要开始的实验提醒
                        let nowStamp = now.hour * 60 + now.minute
                        let thenStamp = then.hour * 60 + then.minute
                        if nowStamp < thenStamp && nowStamp >= thenStamp - 30 {
                            return NotificationModel("即将开始实验，请注意时间，准时参加", model.name, model.timeAndPlace)
                        }
                        
                        // 如果是已经开始还未结束的实验，放弃之前所有操作，直接返回这个实验的提醒
                        let endStamp = thenStamp + 3 * 60
                        if nowStamp >= thenStamp && nowStamp < endStamp {
                            return NotificationModel("实验正在进行中", model.name, model.timeAndPlace)
                        }
                    }
                }
            }
        }
        return nil
    }
}