//
//  CurriculumNotifier.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/6.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

// 每节课开始的时间，以(Hour * 60 + Minute)形式表示
// 本程序假定每节课都是45分钟
let CLASS_BEGIN_TIME = [
    8 * 60, 8 * 60 + 50, 9 * 60 + 50, 10 * 60 + 40, 11 * 60 + 30,
    14 * 60, 14 * 60 + 50, 15 * 60 + 50, 16 * 60 + 40, 17 * 60 + 30,
    18 * 60 + 30, 19 * 60 + 20, 20 * 60 + 10
]

let WEEK_NUMS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

/**
    单次课程信息的类
 */
class ClassInfo {
        
    var className, place : String;
    var weekNum : String = "";
    var startWeek, endWeek, startTime, endTime : Int;
    
    init (json : JSON){
        className = json[0].string!;
        place = json[2].string!;
        let timeStr = json[1].string!;
        var timeStrs = timeStr
            .replaceAll("]", "-")
            .replaceAll("[", "")
            .replaceAll("周", "")
            .replaceAll("节", "")
            .split("-");
        startWeek = Int(timeStrs[0])!;
        endWeek = Int(timeStrs[1])!;
        startTime = Int(timeStrs[2])!;
        endTime = Int(timeStrs[3])!;
    }
    
    func getTimePeriod() -> String {
        return time60ToHourMinute(CLASS_BEGIN_TIME[startTime - 1]) + "~"
            + time60ToHourMinute(CLASS_BEGIN_TIME[endTime - 1] + 45);
    }
    
    func getPeriodCount() -> Int {
        return endTime - startTime + 1;
    }
    
    func isFitEvenOrOdd(weekNum: Int) -> Bool{
        if(weekNum % 2 == 0){
            return !place.containsString("(单)");
        } else {
            return !place.containsString("(双)");
        }
    }
    
    func time60ToHourMinute(time: Int) -> String{
        return String(format: "%d:%02d", time / 60, time % 60);
    }
}

/**
    用来返回课表提醒的工具类，类似于主程序中的CurriculumCard
 */
class CurriculumNotifier {
    
    static func getNotification() -> NotificationModel? {
        
        let cache = CacheHelper.get("herald_curriculum")
        let now = NSDate().timeIntervalSince1970
        if cache == "" {
            return nil
        }
        
        let content = JSON.parse(cache)
        
        // 读取开学日期
        let startMonth = content["startdate"]["month"].intValue
        let startDate = content["startdate"]["day"].intValue
        let cal = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Weekday], fromDate: NSDate())
        let beginOfTerm = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        beginOfTerm.month = startMonth + 1
        beginOfTerm.day = startDate
        
        // 如果开学日期比今天还晚，则是去年开学的。这里用while保证了thisWeek永远大于零
        let nowDate = NSCalendar.currentCalendar().dateFromComponents(cal)!
        var begin = NSCalendar.currentCalendar().dateFromComponents(beginOfTerm)!
        if (nowDate.compare(begin) == NSComparisonResult.OrderedAscending) {
            beginOfTerm.year -= 1
            begin = NSCalendar.currentCalendar().dateFromComponents(beginOfTerm)!
        }
        
        // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
        let k = (NSCalendar.currentCalendar().components([.Weekday], fromDate: begin).weekday + 5) % 7
        
        // 将开学日期往前推到周一
        begin = begin.dateByAddingTimeInterval(Double(-k * 86400))
        
        // 计算当前周
        let thisWeek = Int(nowDate.timeIntervalSinceDate(begin)) / 86400 / 7 + 1
        
        let dayOfWeek = (cal.weekday + 5) % 7
        
        // 枚举今天的课程
        var array = content[WEEK_NUMS[dayOfWeek]].arrayValue
        var classCount = 0
        
        for j in 0 ..< array.count {
            let info = ClassInfo(json: array[j])
            
            // 如果该课程本周上课
            if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                classCount += 1
                // 上课时间
                let today = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Weekday], fromDate: NSDate())
                let startTime = NSCalendar.currentCalendar().dateFromComponents(today)!.timeIntervalSince1970 + Double(CLASS_BEGIN_TIME[info.startTime - 1] * 60)
                
                // 下课时间
                let endTime = NSCalendar.currentCalendar().dateFromComponents(today)!.timeIntervalSince1970 + Double((CLASS_BEGIN_TIME[info.endTime - 1] + 45) * 60)
                
                if now >= startTime - 15 * 60 && now < startTime {
                    // 快要上课的提醒
                    return NotificationModel("即将开始上课，请注意时间，准时上课", info.className, info.getTimePeriod() + " @ " + info.place)
                } else if now >= startTime && now < endTime {
                    // 正在上课的提醒
                    return NotificationModel("正在上课中", info.className, info.getTimePeriod() + " @ " + info.place)
                }
            }
        }
        return nil
    }
}