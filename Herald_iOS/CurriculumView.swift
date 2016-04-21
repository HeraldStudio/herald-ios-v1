//
//  CurriculumView.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/17.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CurriculumView : UIViewController {
    // 常量，我校一天的课时数
    static let PERIOD_COUNT = 13
    
    // 常量，今天所在列与其他列的宽度比值
    static let TODAY_WEIGHT : CGFloat = 1.5
    
    // 星期在JSON中的表示值
    static let WEEK_NUMS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    // 星期在屏幕上的显示值
    static let WEEK_NUMS_CN = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    // 每节课开始的时间，以(Hour * 60 + Minute)形式表示
    // 本程序假定每节课都是45分钟
    static let CLASS_BEGIN_TIME = [
        8 * 60, 8 * 60 + 50, 9 * 60 + 50, 10 * 60 + 40, 11 * 60 + 30,
        14 * 60, 14 * 60 + 50, 15 * 60 + 50, 16 * 60 + 40, 17 * 60 + 30,
        18 * 60 + 30, 19 * 60 + 20, 20 * 60 + 10
    ]
    
    static let BLOCK_COLORS = [
        [245,98,154],[254,141,63],[236,173,7],[161,210,19],
        [18,202,152],[0,171,212],[109,159,244],[159,115,255]
    ]
    
    var obj : JSON!
    var sidebar : [String : String]!
    var week : Int!
    var curWeek : Bool!

    func data (obj : JSON, sidebar : [String : String], week : Int, curWeek : Bool) {
        self.obj = obj
        self.sidebar = sidebar
        self.week = week
        self.curWeek = curWeek
    }
    
    var topPadding : CGFloat = 0
    var width : CGFloat = 0
    var height : CGFloat = 0
    var columnsCount = 7
    
    func loadData () {
        
        width = view.frame.width
        height = view.frame.height
        
        // 绘制表示各课时的水平分割线
        for i in 0 ..< CurriculumView.PERIOD_COUNT {
            let v = UIView(frame: CGRect(x: 0, y: topPadding + CGFloat(i + 1) * height / CGFloat(CurriculumView.PERIOD_COUNT + 1), width: width, height: 1))
            v.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            self.view.addSubview(v)
        }
        
        // 首先假设7天都有课
        columnsCount = 7
        
        // 开始求当天的星期
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit(rawValue: UInt.max), fromDate: NSDate())
        
        // 格里高利历中，weekday范围1~7，1为周日，需要转换成0到6，0为周一
        let dayOfWeek = (components.weekday + 5) % 7
        
        // 双重列表，用每个子列表表示一天的课程
        var listOfList : [[ClassInfo]] = []
        
        // 放两个循环是为了先把列数确定下来
        for i in 0 ..< 7 {
            // 用JSON中对应的String表示的该日星期
            var array = obj[CurriculumView.WEEK_NUMS[i]]
            
            // 剔除不属于本周的课程，并将对应的课程添加到对应星期的列表中
            var list : [ClassInfo] = []
            for j in 0 ..< array.count {
                let info = ClassInfo(json: array[j])
                info.weekNum = CurriculumView.WEEK_NUMS_CN[i]
                let startWeek = info.startWeek
                let endWeek = info.endWeek
                if(endWeek >= week && startWeek <= week && info.isFitEvenOrOdd(week)){
                    list.append(info)
                }
            }
            
            // 根据周六或周日无课的天数对列数进行删减
            if (i >= 5 && list.count == 0) {
                columnsCount -= 1
            }
            
            // 将子列表添加到父列表
            listOfList.append(list)
        }
        
        // 确定好实际要显示的列数后，将每列数据交给子函数处理
        var j = 0
        for i in 0 ..< 7 {
            let list = listOfList[i]
            if (list.count != 0 || i < 5) {
                setColumnData(list, // 这一列的数据
                    sidebar : sidebar,
                    columnIndex : j, // 该列在所有实际要显示的列中的序号
                    dayIndex : i, // 该列在所有列中的序号
                    dayDelta : i - dayOfWeek, // 该列的星期数与今天星期数之差
                    // 是否突出显示与今天同星期的列
                    widenToday : curWeek && (dayOfWeek != 0 && dayOfWeek != 6 ||// TODO 当前周
                        listOfList[dayOfWeek].count != 0))
                j += 1
            }
            
            // TODO 时间指示条
        }
    }
    
    // 绘制某一列的课表
    func setColumnData(list : NSArray, sidebar : [String : String],
                       columnIndex : Int, dayIndex : Int, dayDelta : Int, widenToday : Bool) {
        let N = list.count
        var addition : CGFloat = 0
        if widenToday { addition = CurriculumView.TODAY_WEIGHT - 1 }
        
        var x = CGFloat(columnIndex)
        if dayDelta > 0 { x += addition }
        x *= width / (CGFloat(columnsCount) + addition)
        x += 0.5
        
        var w : CGFloat = 1
        if(dayDelta == 0 && widenToday) { w = CurriculumView.TODAY_WEIGHT }
        w *= width / (CGFloat(columnsCount) + addition)
        
        // 绘制星期标题
        let v = UILabel(frame: CGRect(
            x : x ,
            y : topPadding,
            width : w ,
            height : height / CGFloat(CurriculumView.PERIOD_COUNT + 1)
            ))
        v.text = CurriculumView.WEEK_NUMS_CN[dayIndex]
        v.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        v.textAlignment = .Center
        v.font = UIFont(name: "HelveticaNeue", size: 14)
        v.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(v)
        
        // 显示当天星期标题下面的高亮条
        if (widenToday && dayDelta == 0) {
            let v = UIView(frame: CGRect(x: x, y: topPadding + height / (CGFloat)(CurriculumView.PERIOD_COUNT + 1) - 2, width: w, height: 2))
            v.backgroundColor = UIColor(red: 0, green: 180/255, blue: 255/255, alpha: 1)
            self.view.addSubview(v)
        }
        
        // 绘制每列的竖直分割线
        let v1 = UIView(frame: CGRect(x: x - 0.5, y: topPadding, width: 1, height: height))
        v1.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.view.addSubview(v1)
        
        // 绘制每节课的方块
        for i in 0 ..< N {
            let info = list[i] as! ClassInfo
            let block = CurriculumBlock(frame: CGRect(
                x: x,
                y: topPadding + CGFloat(info.startTime) * height / CGFloat(CurriculumView.PERIOD_COUNT + 1) + 0.5,
                width: w - 1,
                height: CGFloat(info.getPeriodCount()) * height / CGFloat(CurriculumView.PERIOD_COUNT + 1) - 1
                ))
            
            block.text = info.className + "\n" + info.place
            block.textColor = UIColor.whiteColor()
            block.textAlignment = .Center
            block.font = UIFont(name: "HelveticaNeue", size: 13)
            block.lineBreakMode = .ByWordWrapping
            block.numberOfLines = 0
            var a = CurriculumView.BLOCK_COLORS[(info.className.utf16.count + info.className.utf8.count * 2) % CurriculumView.BLOCK_COLORS.count]
            block.layer.backgroundColor = UIColor(
                red: CGFloat(a[0])/255.0,
                green: CGFloat(a[1])/255.0,
                blue: CGFloat(a[2])/255.0,
                alpha: 1.0).CGColor
            block.layer.cornerRadius = 3
            
            block.root = self
            let place = info.place
                .stringByReplacingOccurrencesOfString("(单)", withString: "")
                .stringByReplacingOccurrencesOfString("(双)", withString: "")
            block.info = "课程名称：\(info.className)\n上课地点：\(place)\n上课周次：\(info.startWeek)~\(info.endWeek)周"
            if(info.place.containsString("(单)")){block.info += "单周"}
            if(info.place.containsString("(双)")){block.info += "双周"}
            block.info += "\(info.weekNum)\n上课时间：\(info.startTime)~\(info.endTime)节 (\(info.getTimePeriod()))\n"
            if let additional = sidebar[info.className] {
                block.info += additional
            } else {
                block.info += "获取教师及学分信息失败，请刷新"
            }
            
            block.userInteractionEnabled = true
            let tapStepGestureRecognizer = UITapGestureRecognizer(target: block, action: Selector("showInfo"))
            block.addGestureRecognizer(tapStepGestureRecognizer)
            self.view.addSubview(block)
        }
    }
}
