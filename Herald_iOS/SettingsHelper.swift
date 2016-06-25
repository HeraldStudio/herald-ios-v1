//
//  SettingsHelper.swift/Users/Vhyme/Documents/iOS/Herald_iOS/Herald_iOS
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class SettingsHelper {
    
    /**
     * 应用启动次数
     */
    static var launchTimes : Int {
        get {
            let times = get("herald_settings_launch_time")
            if times == "" {
                set("herald_settings_launch_time", "0")
                return 0
            } else {
                return Int(times)!
            }
        } set {
            set("herald_settings_launch_time", String(newValue))
        }
    }
    
    static let settingsCache = NSUserDefaults.withPrefix("settings_")
    
    static func get (key : String) -> String {
        return settingsCache.get(key)
    }
    
    static func set (key : String, _ value: String) {
        settingsCache.set(key, value)
    }
    
    static var curriculumNotificationEnabled : Bool {
        get {
            return get("curriculum_notification_enabled") == "1"
        } set {
            set("curriculum_notification_enabled", newValue ? "1" : "0")
        }
    }
    
    static var experimentNotificationEnabled : Bool {
        get {
            return get("experiment_notification_enabled") != "0"
        } set {
            set("experiment_notification_enabled", newValue ? "1" : "0")
        }
    }
    
    static var examNotificationEnabled : Bool {
        get {
            return get("exam_notification_enabled") != "0"
        } set {
            set("exam_notification_enabled", newValue ? "1" : "0")
        }
    }
}