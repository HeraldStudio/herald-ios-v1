//
//  CurriculumCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * 读取课表缓存，转换成对应的首页卡片条目
 **/
class TodayCurriculumList {
    
    static var classList : [ClassModel] {
        if !ApiHelper.isLogin() {
            return []
        }
        if Cache.curriculum.isEmpty {
            return []
        }
        
        let now = GCalendar()
        let cache = Cache.curriculum.value
        
        let content = JSON.parse(cache)
        
        // 读取开学日期
        let startMonth = content["startdate"]["month"].intValue
        let startDate = content["startdate"]["day"].intValue
        let nowDate = GCalendar(.Day)
        let beginOfTerm = GCalendar(.Day)
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        beginOfTerm.month = startMonth + 1
        beginOfTerm.day = startDate
        
        // 如果开学日期比今天晚了超过两个月，则认为是去年开学的。这里用while保证了thisWeek永远大于零
        while (beginOfTerm - nowDate > 60 * 86400) {
            beginOfTerm.year -= 1
        }
        
        // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
        let k = beginOfTerm.dayOfWeekFromMonday.rawValue
        
        // 将开学日期往前推到周一
        beginOfTerm -= k * 86400
        
        // 计算当前周
        let dayDelta = (nowDate - beginOfTerm) / 86400
        if dayDelta < -1 {
            return []
        }
        
        var thisWeek = dayDelta / 7 + 1
        
        var dayOfWeek = nowDate.dayOfWeekFromMonday.rawValue
        
        // 枚举今天的课程
        var array = content[WEEK_NUMS[dayOfWeek]].arrayValue
        
        var remainingClasses : [ClassModel] = []
        
        for j in 0 ..< array.count {
            do {
                let info = try ClassModel(json: array[j])
                
                // 如果该课程今天上课
                if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                    
                    // 只要是没超过下课时间的课就显示
                    let endTime = GCalendar(.Day) + (CLASS_BEGIN_TIME[info.endTime - 1] + 45) * 60
                    
                    if now < endTime {
                        remainingClasses.append(info)
                    }
                }
            } catch {
                // 该课程信息不标准，例如辅修课等，无法被识别，则跳过
            }
        }
        
        // 这里跟app内部不同，不管今天有没有课都顺带着显示一下明天的课
        // 枚举明天的课程
        dayOfWeek += 1
        thisWeek += dayOfWeek / 7
        dayOfWeek %= 7
        array = content[WEEK_NUMS[dayOfWeek]].arrayValue
        
        for j in 0 ..< array.count {
            do {
                let info = try ClassModel(json: array[j])
                // 如果该课程本周上课
                if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                    info.weekNum = "明天 "
                    remainingClasses.append(info)
                }
            } catch {}
        }
        
        return remainingClasses
    }
}
