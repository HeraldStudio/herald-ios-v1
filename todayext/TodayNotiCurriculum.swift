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
class TodayNotiCurriculum {
    
    static func getNoti() -> String? {
        if !ApiHelper.isLogin() {
            return nil
        }
        if Cache.curriculum.isEmpty {
            return "请打开小猴刷新课表"
        }
        
        let now = GCalendar()
        let cache = Cache.curriculum.value
        
        let content = JSON.parse(cache)["content"]
        
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
            return nil
        } else if dayDelta == -1 {
            return nil
        }
        
        let thisWeek = dayDelta / 7 + 1
        
        let dayOfWeek = nowDate.dayOfWeekFromMonday.rawValue
        
        // 枚举今天的课程
        var array = content[WEEK_NUMS[dayOfWeek]].arrayValue
        var classCount = 0
        var remainingClasses = [ClassModel]()
        
        for j in 0 ..< array.count {
            do {
                let info = try ClassModel(json: array[j])
                info.weekNum = WEEK_NUMS_CN[dayOfWeek]
                
                // 如果该课程本周上课
                if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                    classCount += 1
                    // 上课时间
                    let startTime = GCalendar(.Day) + CLASS_BEGIN_TIME[info.startTime - 1] * 60
                    
                    // 下课时间
                    let endTime = GCalendar(.Day) + (CLASS_BEGIN_TIME[info.endTime - 1] + 45) * 60
                    
                    // 快要下课的时间
                    let almostEndTime = endTime - 10 * 60
                    
                    // 如果是还没到时间的课，放在“你今天(还)有x节课”的列表里备用
                    // 只要没有快上课或正在上课的提醒导致中途退出循环的话，这个列表就会显示
                    if now < startTime {
                        remainingClasses.append(info)
                    }
                    
                    // 快要上课的紧急提醒
                    if now >= startTime - 15 * 60 && now < startTime {
                        return "即将上课：" + info.className + " @ " + info.place
                    } else if now >= startTime && now < almostEndTime {
                        return "正在上课：" + info.className + " @ " + info.place
                    }
                }
            } catch {
                // 该课程信息不标准，例如辅修课等，无法被识别，则跳过
            }
        }
        // 此处退出循环有三种可能：可能是今天没课，可能是课与课之间或早上的没上课状态，也可能是课上完了的状态
        
        // 如果不是课上完了的状态
        if remainingClasses.count > 0 {
            let info = remainingClasses[0]
            return "下节课：" + info.getTimePeriod() + " " + info.className
        }
        
        // 课上完了的状态
        return "你没有新的课程或实验"
    }
}
