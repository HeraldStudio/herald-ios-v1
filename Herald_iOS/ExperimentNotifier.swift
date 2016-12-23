//
//  ExperimentNotifier.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/13.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExperimentNotifier {
    static func scheduleNotificationsForExperiment (_ model : ExperimentModel) {
        guard model.timeAndPlace.split("）").count > 1 else { return }
        let cal = GCalendar(model.timeAndPlace.split("（")[0] + model.timeAndPlace.split("）")[1].split("@")[0].replaceAll("上午", " 9:45 ").replaceAll("下午", " 13:45 ").replaceAll("晚上", " 18:15 "))
        cal -= 15 * 60
        
        if cal < GCalendar() { return }
        
        //debugPrint("Sheduled notification: Experiment \(model.name), \(cal)")
        let date = cal.getDate()
        
        let not = UILocalNotification()
        not.fireDate = date
        not.timeZone = TimeZone.current
        not.soundName = UILocalNotificationDefaultSoundName
        not.applicationIconBadgeNumber = 1
        guard model.timeAndPlace.split("@").count > 1 else { return }
        let place = model.timeAndPlace.split("@")[1]
        not.alertBody = "[实验地点 \(place)] " + model.name + " 将在15分钟后开始实验，请注意时间，准时参加"
        
        UIApplication.shared.scheduleLocalNotification(not)
    }
    
    static func scheduleNotifications () {
        let cache = Cache.experiment.value
        let content = JSON.parse(cache)["content"]
        
        for section in content {
            let array = section.1
            if array.count == 0 {
                continue
            }
            
            for json in array.arrayValue {
                scheduleNotificationsForExperiment(ExperimentModel(json: json))
            }
        }
    }
}
