//
//  SettingsHelper.swift/Users/Vhyme/Documents/iOS/Herald_iOS/Herald_iOS
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

enum Module : Int {
    case Card
    case Pedetail
    case Curriculum
    case Experiment
    case Lecture
    case Jwc
    case Exam
    case SeuNet
    case Library
    case Grade
    case Srtp
    case Schoolbus
    case Schedule
    case GymReserve
    case Quanyi
    case EmptyRoom
}

class SettingsHelper {
    static let MODULES : [AppModule] = [
        
        // 有卡片的模块
        AppModule(0, "cardextra", "一卡通", "提供一卡通消费情况查询、一卡通在线充值以及余额提醒服务", "MODULE_QUERY_CARDEXTRA", "ic_card", true),
        AppModule(1, "pedetail", "跑操助手", "提供跑操次数及记录查询、早操预报以及跑操到账提醒服务", "MODULE_QUERY_PEDETAIL", "ic_pedetail", true),
        AppModule(2, "curriculum", "课表助手", "浏览当前学期的课表信息，并提供上课提醒服务", "MODULE_QUERY_CURRICULUM", "ic_curriculum", true),
        AppModule(3, "experiment", "实验助手", "浏览当前学期的实验信息，并提供实验提醒服务", "MODULE_QUERY_EXPERIMENT", "ic_experiment", true),
        AppModule(4, "lecture", "人文讲座", "查看人文讲座听课记录，并提供人文讲座预告信息", "MODULE_QUERY_LECTURE", "ic_lecture", true),
        AppModule(5, "jwc", "教务通知", "显示教务处最新通知，提供重要教务通知提醒服务", "MODULE_QUERY_JWC", "ic_jwc", true),
        AppModule(6, "exam", "考试助手", "查询个人考试安排，提供考试倒计时提醒服务", "MODULE_QUERY_EXAM", "ic_exam", true),
        
        // 无卡片的模块
        AppModule(7, "seunet", "校园网络", "显示校园网使用情况及校园网账户余额信息", "MODULE_QUERY_SEUNET", "ic_seunet", false),
        AppModule(8, "library", "图书馆", "查看图书馆实时借阅排行、已借书籍，并提供图书在线续借服务", "MODULE_QUERY_LIBRARY", "ic_library", false),
        AppModule(9, "grade", "成绩查询", "查询历史学期的科目成绩、学分以及绩点详情", "MODULE_QUERY_GRADE", "ic_grade", false),
        AppModule(10, "srtp", "课外研学", "提供SRTP学分及得分详情查询服务", "MODULE_QUERY_SRTP", "ic_srtp", false),
        AppModule(11, "schoolbus", "校车助手", "提供可实时更新的校车班车时间表", "MODULE_QUERY_SCHOOLBUS", "ic_bus", false),
        AppModule(12, "schedule", "校历查询 Web", "显示当前年度各学期的学校校历安排", "http://heraldstudio.com/static/images/xiaoli.jpg", "ic_schedule", false),
        AppModule(13, "gymreserve", "场馆预约 Web", "提供体育场馆在线预约和查询服务", "http://115.28.27.150/heraldapp/#/yuyue/home", "ic_gymreserve", false),
        AppModule(14, "quanyi", "权益服务 Web", "向东大校会权益部反馈投诉信息", "https://jinshuju.net/f/By3aTK", "ic_quanyi", false),
        AppModule(15, "emptyroom", "空教室 Web", "提供指定时间内的空教室信息查询服务", "http://115.28.27.150/queryEmptyClassrooms/m", "ic_emptyroom", false)
    ]
    
    static func setDefaultConfig () {
        setDefaultShortcutEnabled()
    }
    
    static func setDefaultShortcutEnabled () {
        // 默认快捷栏只显示无卡片的模块
        for i in 0 ..< MODULES.count {
            setModuleShortCutEnabled(i, enabled: !MODULES[i].hasCard)
        }
    }
    
    /**
     * 用于设置某个模块是否在快捷方式盒子中显示
     *
     * @param moduleID 模块ID
     * @param flag     true为启用，false为禁用
     */
    static func setModuleShortCutEnabled(moduleID : Int, enabled : Bool) {
    // flag为true则设置为选中，否则设置为不选中
    if (enabled) {
            set("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name, "1")
        } else {
            set("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name, "0")
        }
    }
    
    /**
     * 获得某个模块的快捷方式显示情况
     *
     * @param moduleID 模块ID
     */
    static func getModuleShortcutEnabled (moduleID : Int) -> Bool {
        //获得某项模块的卡片是否显示
        return get("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name) != "0"
    }
    
    /**
     * 用于设置某个模块是否在首页卡片中显示
     *
     * @param moduleID 模块ID
     * @param flag     true为启用，false为禁用
     */
    static func setModuleCardEnabled(moduleID : Int, enabled : Bool) {
        if !MODULES[moduleID].hasCard { return }
        // flag为true则设置为选中，否则设置为不选中
        if (enabled) {
            set("herald_settings_module_cardenabled_" + MODULES[moduleID].name, "1")
        } else {
            set("herald_settings_module_cardenabled_" + MODULES[moduleID].name, "0")
        }
    }
    
    /**
     * 获得某个模块在首页卡片中的显示情况
     *
     * @param moduleID 模块ID
     */
    static func getModuleCardEnabled (moduleID : Int) -> Bool {
        //获得某项模块的卡片是否显示
        return MODULES[moduleID].hasCard && get("herald_settings_module_cardenabled_" + MODULES[moduleID].name) != "0"
    }
    
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
     * 获得应用启动次数
     */
    static func getLaunchTimes () -> Int {
        let times = get("herald_settings_launch_time")
        if times == "" {
            set("herald_settings_launch_time", "0")
            return 0
        } else {
            return Int(times)!
        }
    }
    
    /**
     * 设置应用启动次数
     *
     * @param times 要设置的次数
     */
    static func updateLaunchTimes (times : Int) {
        set("herald_settings_launch_time", String(times))
    }
    
    static let settingsCache = NSUserDefaults.withPrefix("settings_")
    
    static func get (key : String) -> String {
        return settingsCache.get(key)
    }
    
    static func set (key : String, _ value: String) {
        settingsCache.set(key, value)
    }
}