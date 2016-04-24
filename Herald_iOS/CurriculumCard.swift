//
//  CurriculumCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//
/*
import Foundation
import SwiftyJSON

/**
 * 读取课表缓存，转换成对应的首页卡片条目
 **/
class CurriculumCard : CardsModel {
    
    init() {
        let cache = CacheHelper.get("herald_curriculum")
        let now = NSDate().timeIntervalSince1970
        if cache == "" {
            super.init(SettingsHelper.MODULES[2], "课表数据加载失败，请手动刷新", "", Priority.NO_CONTENT)
            return
        }
        
        let content = JSON.parse(cache)
        // 读取侧栏信息
        let sidebar = CacheHelper.get("herald_sidebar")
        var sidebarInfo : [String : String] = [:]
        
        // 将课程的授课教师放入键值对
        let sidebarArray = JSON.parse(sidebar).arrayValue
        for k in sidebarArray {
            sidebarInfo.updateValue(k["lecturer"].stringValue, forKey: k["course"].stringValue)
        }
        // 读取开学日期
        let startMonth = content["startdate"]["month"].intValue
        let startDate = content["startdate"]["day"].intValue
        let mostUnits = NSCalendarUnit(rawValue: UInt.max)
        let cal = NSCalendar.currentCalendar().components(mostUnits, fromDate: NSDate())
        let beginOfTerm = NSCalendar.currentCalendar().components(mostUnits, fromDate: NSDate())
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        beginOfTerm.month = startMonth + 1
        beginOfTerm.day = startDate
        
        // 如果开学日期比今天还晚，则是去年开学的。这里用while保证了thisWeek永远大于零
        let nowDate = cal.date!
        var begin = beginOfTerm.date!
        while (cal.date?.compare(beginOfTerm.date!) == NSComparisonResult.OrderedAscending) {
            cal.year -= 1
        }
        
        // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit(rawValue: UInt.max), fromDate: begin)
        
        // 格里高利历中，weekday范围1~7，1为周日，需要转换成0到6，0为周一
        let dayOfWeek = (components.weekday + 5) % 7
        
        // 将开学日期往前推到周一
        begin = begin.dateByAddingTimeInterval(Double(-dayOfWeek * 86400))
        
        // 计算当前周
        let thisWeek = Int(nowDate.timeIntervalSinceDate(begin)) / 86400 / 7 + 1
        
        // 枚举今天的课程
        let array = content[CurriculumView.WEEK_NUMS[dayOfWeek]].arrayValue
        var classCount = 0
        var classAlmostEnd = false
        
        var remainingClasses : [UIView] = []
        
        
    }
}*/ // TODO 没写完