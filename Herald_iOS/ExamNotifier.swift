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
                let examItem = try ExamModel(json: exam)
                let cal = GCalendar(examItem.timeAndPlace.split("@")[0])
                cal -= 30 * 60
                if cal < GCalendar() { return }
                
                debugPrint("Sheduled notification: Exam \(examItem.course), \(cal)")
                let not = UILocalNotification()
                not.fireDate = cal.getDate()
                not.timeZone = NSTimeZone.defaultTimeZone()
                not.soundName = UILocalNotificationDefaultSoundName
                
                guard examItem.timeAndPlace.split("@").count > 1 else { return }
                let place = examItem.timeAndPlace.split("@")[1]
                not.alertBody = "[\(place)] " + examItem.course + " 将在半小时后开始考试，请注意时间，准时参加"
                
                UIApplication.sharedApplication().scheduleLocalNotification(not)
            } catch { continue }
        }
    }
}