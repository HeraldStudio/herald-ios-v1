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
class CurriculumCard {
    
    static func getRefresher () -> ApiRequest {
        return Cache.curriculum.refresher | Cache.curriculumSidebar.refresher
    }
    
    static func getCard() -> CardsModel {
        if !ApiHelper.isLogin() {
            return CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "登录即可使用课表查询、智能提醒功能", priority: .NO_CONTENT)
        }
        if Cache.curriculum.isEmpty {
            return CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "课表数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let now = GCalendar()
        let cache = Cache.curriculum.value
        
        let content = JSON.parse(cache)
        // 读取侧栏信息
        let sidebar = Cache.curriculumSidebar.value
        var sidebarInfo : [String : String] = [:]
        
        // 将课程的授课教师放入键值对
        let sidebarArray = JSON.parse(sidebar).arrayValue
        for k in sidebarArray {
            sidebarInfo.updateValue(k["lecturer"].stringValue, forKey: k["course"].stringValue)
        }
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
            return CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "还没有开学，点击预览新学期课表~", priority: .CONTENT_NO_NOTIFY)
        } else if dayDelta == -1 {
            return CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "明天就要开学了，点击预览新学期课表~", priority: .CONTENT_NOTIFY)
        }
        
        var thisWeek = dayDelta / 7 + 1
        
        var dayOfWeek = nowDate.dayOfWeekFromMonday.rawValue
        
        // 枚举今天的课程
        var array = content[CurriculumView.WEEK_NUMS[dayOfWeek]].arrayValue
        var classCount = 0
        var classAlmostEnd = false
        
        var remainingClasses : [CardsRowModel] = []
        
        for j in 0 ..< array.count {
            do {
                let info = try ClassModel(json: array[j])
                info.weekNum = CurriculumView.WEEK_NUMS_CN[dayOfWeek]
                let _teacher = sidebarInfo[info.className]
                let teacher = _teacher != nil ? _teacher! : ""
                let row = CardsRowModel(classModel: info, teacher: teacher)
                
                // 如果该课程本周上课
                if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                    classCount += 1
                    // 上课时间
                    let startTime = GCalendar(.Day) + CurriculumView.CLASS_BEGIN_TIME[info.startTime - 1] * 60
                    
                    // 下课时间
                    let endTime = GCalendar(.Day) + (CurriculumView.CLASS_BEGIN_TIME[info.endTime - 1] + 45) * 60

                    // 快要下课的时间
                    let almostEndTime = endTime - 10 * 60
                    
                    // 如果是还没到时间的课，放在“你今天(还)有x节课”的列表里备用
                    // 只要没有快上课或正在上课的提醒导致中途退出循环的话，这个列表就会显示
                    if now < startTime {
                        if now >= almostEndTime && now < endTime {
                            classAlmostEnd = true
                        }
                        remainingClasses.append(row)
                    }
                    
                    // 快要上课的紧急提醒
                    if now >= startTime - 15 * 60 && now < startTime {
                        let model = CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "即将开始上课，请注意时间，准时上课", priority: .CONTENT_NOTIFY)
                        model.rows.append(row)
                        return model
                    } else if now >= startTime && now < almostEndTime {
                        // 正在上课的提醒
                        let model = CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: "正在上课中", priority: .CONTENT_NOTIFY)
                        model.rows.append(row)
                        return model
                    }
                }
            } catch {
                // 该课程信息不标准，例如辅修课等，无法被识别，则跳过
            }
        }
        // 此处退出循环有三种可能：可能是今天没课，可能是课与课之间或早上的没上课状态，也可能是课上完了的状态
        
        // 如果不是课上完了的状态
        if remainingClasses.count > 0 {
            let firstClass = remainingClasses.count == classCount
            let model = CardsModel(cellId: "CardsCellCurriculum", module: ModuleCurriculum, desc: (classAlmostEnd ? "快要下课了，" : "") +
                (firstClass ? "你今天有" : "你今天还有") + String(remainingClasses.count) + "节课，点我查看详情", priority: .CONTENT_NO_NOTIFY)
            model.rows.append(contentsOf: remainingClasses)
            return model
        }
        
        // 课上完了的状态
        
        // 若今天没课，或者课上完了，显示明天课程
        // 枚举明天的课程
        dayOfWeek += 1
        thisWeek += dayOfWeek / 7
        dayOfWeek %= 7
        array = content[CurriculumView.WEEK_NUMS[dayOfWeek]].arrayValue
        let todayHasClasses = classCount != 0
        
        classCount = 0
        var rowList : [CardsRowModel] = []
        for j in 0 ..< array.count {
            do {
                let info = try ClassModel(json: array[j])
                info.weekNum = CurriculumView.WEEK_NUMS_CN[dayOfWeek]
                let _teacher = sidebarInfo[info.className]
                let teacher = _teacher != nil ? _teacher! : ""
                let row = CardsRowModel(classModel: info, teacher: teacher)
                // 如果该课程本周上课
                if info.startWeek <= thisWeek && info.endWeek >= thisWeek && info.isFitEvenOrOdd(thisWeek) {
                    classCount += 1
                    rowList.append(row)
                }
            } catch {}
        }
        let model = CardsModel(cellId: "CardsCellCurriculum",
                               module: ModuleCurriculum,
                               desc:
            // 如果明天没课
            classCount == 0 ? (todayHasClasses ? "明天" : "今明两天都") + "没有课程，娱乐之余请注意作息安排哦"
            // 如果明天有课
                : (todayHasClasses ? "今天的课程已经结束，" : "今天没有课程，") + "明天有\(classCount)节课",
            // 若明天有课，则属于有内容不提醒状态；否则属于无内容状态
            priority: classCount == 0 ? .NO_CONTENT : .CONTENT_NO_NOTIFY)
        model.rows.append(contentsOf: rowList)
        return model
    }
}
