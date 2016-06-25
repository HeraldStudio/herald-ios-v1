//
//  CurriculumNotifier.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/13.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CurriculumNotifier {
    
    static func scheduleNotificationsForClassInfo (info : ClassInfo, startDate : GCalendar) {
        for week in info.startWeek ..< info.endWeek + 1 {
            if info.isFitEvenOrOdd(week) {
                let cal = GCalendar(startDate)
                cal += (week - 1) * 7 * 24 * 60 * 60
                cal += info.weekDay * 24 * 60 * 60
                cal += CurriculumView.CLASS_BEGIN_TIME[info.startTime - 1] * 60
                cal -= 15 * 60
                if cal < GCalendar() { continue }
                
                //debugPrint("Sheduled notification: Curriculum \(info.className), \(cal)")
                let date = cal.getDate()
                
                let not = UILocalNotification()
                not.fireDate = date
                not.timeZone = NSTimeZone.defaultTimeZone()
                not.soundName = UILocalNotificationDefaultSoundName
                not.applicationIconBadgeNumber = 1
                let place = info.place.replaceAll("(单)", "").replaceAll("(双)", "")
                not.alertBody = "[\(place)] " + info.className + " 将在15分钟后开始上课，请注意时间，准时上课"
                
                UIApplication.sharedApplication().scheduleLocalNotification(not)
            }
        }
    }

    static func scheduleNotifications () {
        let cache = CacheHelper.get("herald_curriculum")
        if cache == "" { return }
        let content = JSON.parse(cache)
        
        // 读取开学日期
        let startMonth = content["startdate"]["month"].intValue
        let startDate = content["startdate"]["day"].intValue
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        let cal = GCalendar(.Day)
        cal.month = startMonth + 1
        cal.day = startDate
        
        // 如果开学日期比今天还晚，则是去年开学的。这里用while保证了thisWeek永远大于零
        while (cal > GCalendar()) {
            cal.year -= 1
        }
        
        // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
        cal -= cal.dayOfWeekFromMonday.rawValue * 24 * 60 * 60
        
        for i in 0 ..< 7 {
            for k in content[CurriculumView.WEEK_NUMS[i]].arrayValue {
                do {
                    let classInfo = try ClassInfo(json: k)
                    classInfo.weekDay = i
                    scheduleNotificationsForClassInfo(classInfo, startDate: cal)
                } catch {}
            }
        }
    }
}