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
     * 获得是否选择自动登录seu
     */
    static func getWifiAutoLogin () -> Bool {
        let seuauto = get("herald_settings_wifi_autologin")
        return seuauto != "0"
    }
    
    static func setWifiAutoLogin (enabled : Bool) {
        set("herald_settings_wifi_autologin", enabled ? "1" : "0")
    }
    
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
}