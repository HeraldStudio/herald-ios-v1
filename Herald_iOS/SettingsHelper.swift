import Foundation
import UIKit

class SettingsHelper {

    /// 本 Helper 的缓存已经改成随用户变化，退出登录时不再需要清空
    static var settingsCache : PrefixUserDefaults {
        return NSUserDefaults.withPrefix("settings_\(ApiHelper.currentUser.userName)_")
    }
    
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