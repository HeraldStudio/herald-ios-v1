//
//  ExamNotifier.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/13.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExamNotifier {
    static func scheduleNotifications() {
        let cache = CacheHelper.get("herald_exam")
        let json = JSON.parse(cache)["content"]
        
        for exam in json.arrayValue {
            do {
                scheduleNotificationsForExam(try ExamModel(json: exam))
            } catch { continue }
        }
        
        let customCache = CacheHelper.get("herald_exam_custom_\(ApiHelper.getUserName())")
        let jsonCustom = JSON.parse(customCache)
        
        for exam in jsonCustom.arrayValue {
            do {
                scheduleNotificationsForExam(try ExamModel(json: exam))
            } catch { continue }
        }
    }
    
    static func scheduleNotificationsForExam(model : ExamModel){
        let cal = GCalendar(model.time)
        cal -= 30 * 60
        if cal < GCalendar() { return }
        
        let not = UILocalNotification()
        not.fireDate = cal.getDate()
        not.timeZone = NSTimeZone.defaultTimeZone()
        not.soundName = UILocalNotificationDefaultSoundName
        not.applicationIconBadgeNumber = 1
        not.alertBody = (model.location == "" ? "" : "[\(model.location)] ") + model.course + " 将在半小时后开始考试，请注意时间，准时参加"
        
        UIApplication.sharedApplication().scheduleLocalNotification(not)
    }
}