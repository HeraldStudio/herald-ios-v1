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
    
    // 摇一摇默认关闭
    static var wifiAutoLogin : Bool {
        get {
            return get("herald_settings_wifi_autologin") == "1"
        } set {
            set("herald_settings_wifi_autologin", newValue ? "1" : "0")
        }
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
    
    /// 模块设置变化的监听器
    typealias ModuleSettingsChangeListener = () -> Void
    
    static var moduleSettingsChangeListeners : [ModuleSettingsChangeListener] = []
    
    static func addModuleSettingsChangeListener (listener : ModuleSettingsChangeListener) {
        moduleSettingsChangeListeners.append(listener)
    }
    
    static func notifyModuleSettingsChanged () {
        for function in moduleSettingsChangeListeners {
            function()
        }
    }
}