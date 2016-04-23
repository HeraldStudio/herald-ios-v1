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
    static let MODULES : [AppModule] = [
        
        // 有卡片的模块
        AppModule(id: 0, name: "cardextra", nameTip: "一卡通", desc: "提供一卡通消费情况查询、一卡通在线充值以及余额提醒服务", controller: "MODULE_QUERY_CARDEXTRA", icon: "ic_card", hasCard: true),
        AppModule(id: 1, name: "pedetail", nameTip: "跑操助手", desc: "提供跑操次数及记录查询、早操预报以及跑操到账提醒服务", controller: "MODULE_QUERY_PEDETAIL", icon: "ic_pedetail", hasCard: true),
        AppModule(id: 2, name: "curriculum", nameTip: "课表助手", desc: "浏览当前学期的课表信息，并提供上课提醒服务", controller: "MODULE_QUERY_CURRICULUM", icon: "ic_curriculum", hasCard: true),
        AppModule(id: 3, name: "experiment", nameTip: "实验助手", desc: "浏览当前学期的实验信息，并提供实验提醒服务", controller: "MODULE_QUERY_EXPERIMENT", icon: "ic_experiment", hasCard: true),
        AppModule(id: 4, name: "lecture", nameTip: "人文讲座", desc: "查看人文讲座听课记录，并提供人文讲座预告信息", controller: "MODULE_QUERY_LECTURE", icon: "ic_lecture", hasCard: true),
        AppModule(id: 5, name: "jwc", nameTip: "教务通知", desc: "显示教务处最新通知，提供重要教务通知提醒服务", controller: "MODULE_QUERY_JWC", icon: "ic_jwc", hasCard: true),
        AppModule(id: 6, name: "exam", nameTip: "考试助手", desc: "查询个人考试安排，提供考试倒计时提醒服务", controller: "MODULE_QUERY_EXAM", icon: "ic_exam", hasCard: true),
        
        // 无卡片的模块
        AppModule(id: 7, name: "seunet", nameTip: "校园网络", desc: "显示校园网使用情况及校园网账户余额信息", controller: "MODULE_QUERY_SEUNET", icon: "ic_seunet", hasCard: false),
        AppModule(id: 8, name: "library", nameTip: "图书馆*", desc: "查看图书馆实时借阅排行、已借书籍和馆藏图书搜索", controller: "MODULE_QUERY_LIBRARY", icon: "ic_library", hasCard: false),
        AppModule(id: 9, name: "grade", nameTip: "成绩查询", desc: "查询历史学期的科目成绩、学分以及绩点详情", controller: "MODULE_QUERY_GRADE", icon: "ic_grade", hasCard: false),
        AppModule(id: 10, name: "srtp", nameTip: "课外研学*", desc: "提供SRTP学分及得分详情查询服务", controller: "MODULE_QUERY_SRTP", icon: "ic_srtp", hasCard: false),
        AppModule(id: 11, name: "schoolbus", nameTip: "校车助手", desc: "提供可实时更新的校车班车时间表", controller: "MODULE_QUERY_SCHOOLBUS", icon: "ic_bus", hasCard: false),
        AppModule(id: 12, name: "schedule", nameTip: "校历查询", desc: "显示当前年度各学期的学校校历安排", controller: "http://heraldstudio.com/static/images/xiaoli.jpg", icon: "ic_schedule", hasCard: false),
        AppModule(id: 13, name: "gymreserve", nameTip: "场馆预约", desc: "提供体育场馆在线预约和查询服务", controller: "http://115.28.27.150/heraldapp/#/yuyue/home", icon: "ic_gymreserve", hasCard: false),
        AppModule(id: 14, name: "quanyi", nameTip: "权益服务", desc: "向东大校会权益部反馈投诉信息", controller: "https://jinshuju.net/f/By3aTK", icon: "ic_quanyi", hasCard: false),
        AppModule(id: 15, name: "emptyroom", nameTip: "空教室", desc: "提供指定时间内的空教室信息查询服务", controller: "http://115.28.27.150/queryEmptyClassrooms/m", icon: "ic_emptyroom", hasCard: false)
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
            setCache("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name, withValue: "1")
        } else {
            setCache("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name, withValue: "0")
        }
    }
    
    /**
     * 获得某个模块的快捷方式显示情况
     *
     * @param moduleID 模块ID
     */
    static func getModuleShortcutEnabled (moduleID : Int) -> Bool {
        //获得某项模块的卡片是否显示
        return getCache("herald_settings_module_shortcutenabled_" + MODULES[moduleID].name) != "0"
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
            setCache("herald_settings_module_cardenabled_" + MODULES[moduleID].name, withValue: "1")
        } else {
            setCache("herald_settings_module_cardenabled_" + MODULES[moduleID].name, withValue: "0")
        }
    }
    
    /**
     * 获得某个模块在首页卡片中的显示情况
     *
     * @param moduleID 模块ID
     */
    static func getModuleCardEnabled (moduleID : Int) -> Bool {
        //获得某项模块的卡片是否显示
        return MODULES[moduleID].hasCard && getCache("herald_settings_module_cardenabled_" + MODULES[moduleID].name) != "0"
    }
    
    /**
     * 获得所有模块的快捷方式设置情况对象
     */
    static func getSeuModuleList () -> [AppModule] {
        //获得所有模块快捷方式设置列表
        for i in 0 ..< MODULES.count {
            MODULES[i].cardEnabled = getModuleCardEnabled(i)
            MODULES[i].shortcutEnabled = getModuleShortcutEnabled(i)
        }
        return MODULES
    }
    
    /**
     * 获得是否选择自动登录seu
     */
    static func getWifiAutoLogin () -> Bool {
        let seuauto = getCache("herald_settings_wifi_autologin")
        return seuauto != "0"
    }
    
    static func setWifiAutoLogin (enabled : Bool) {
        setCache("herald_settings_wifi_autologin", withValue: enabled ? "1" : "0")
    }
    
    /**
     * 获得应用启动次数
     */
    static func getLaunchTimes () -> Int {
        let times = getCache("herald_settings_launch_time")
        if times == "" {
            setCache("herald_settings_launch_time", withValue: "0")
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
        setCache("herald_settings_launch_time", withValue: String(times))
    }
    
    static let settingsCache = NSUserDefaults.withPrefix("settings_")
    
    static func getCache (key : String) -> String {
        return settingsCache.get(key)
    }
    
    static func setCache (key : String, withValue : String) {
        settingsCache.put(key, withValue: withValue)
    }
}