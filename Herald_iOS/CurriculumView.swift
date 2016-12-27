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
    
    static let BLOCK_COLORS = [
        [245,98,154],[254,141,63],[236,173,7],[161,210,19],
        [18,202,152],[0,171,212],[109,159,244],[159,115,255]
    ]
    
    var obj : JSON!
    var sidebar : [String : String]!
    var week : Int!
    var curWeek : Bool!
    var beginOfTerm : GCalendar!
    var fontSize : CGFloat!

    func data (obj : JSON, sidebar : [String : String], week : Int, curWeek : Bool, beginOfTerm : GCalendar) {
        self.obj = obj
        self.sidebar = sidebar
        self.week = week
        self.curWeek = curWeek
        self.beginOfTerm = beginOfTerm
        fontSize = min(15, self.view.bounds.width / 30)
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
        let dayOfWeek = GCalendar(.Day).dayOfWeekFromMonday.rawValue
        
        // 双重列表，用每个子列表表示一天的课程
        var listOfList : [[ClassModel]] = []
        
        // 放两个循环是为了先把列数确定下来
        for i in 0 ..< 7 {
            // 用JSON中对应的String表示的该日星期
            var array = obj[WEEK_NUMS[i]]
            
            // 剔除不属于本周的课程，并将对应的课程添加到对应星期的列表中
            var list : [ClassModel] = []
            for j in 0 ..< array.count {
                do {
                    let info = try ClassModel(json: array[j])
                    info.weekNum = WEEK_NUMS_CN[i]
                    let startWeek = info.startWeek
                    let endWeek = info.endWeek
                    if(endWeek >= week && startWeek <= week && info.isFitEvenOrOdd(week)){
                        list.append(info)
                    }
                } catch {}
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
                setColumnData(
                    list: list, // 这一列的数据
                    sidebar : sidebar,
                    columnIndex : j, // 该列在所有实际要显示的列中的序号
                    dayIndex : i, // 该列在所有列中的序号
                    dayDelta : i - dayOfWeek, // 该列的星期数与今天星期数之差
                    // 是否突出显示与今天同星期的列
                    widenToday : curWeek && (dayOfWeek < 5 || listOfList[dayOfWeek].count != 0))
                j += 1
            }
        }
    }
    
    // 绘制某一列的课表
    func setColumnData(list : [Any], sidebar : [String : String],
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
        let cal = GCalendar(beginOfTerm)
        cal += ((week - 1) * 7 + dayIndex) * 86400
        
        let v = UILabel(frame: CGRect(
            x : x ,
            y : topPadding,
            width : w ,
            height : height / CGFloat(CurriculumView.PERIOD_COUNT + 1)
            ))
        v.text = String(format: "%d月%d日\n\(WEEK_NUMS_CN[dayIndex])", cal.month, cal.day)
        v.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        v.textAlignment = .center
        v.numberOfLines = 0
        v.font = UIFont(name: "HelveticaNeue", size: fontSize)
        v.backgroundColor = UIColor.white
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
            let info = list[i] as! ClassModel
            let block = CurriculumBlock(frame: CGRect(
                x: x,
                y: topPadding + CGFloat(info.startTime) * height / CGFloat(CurriculumView.PERIOD_COUNT + 1) + 0.5,
                width: w - 1,
                height: CGFloat(info.getPeriodCount()) * height / CGFloat(CurriculumView.PERIOD_COUNT + 1) - 1
                ))
            
            block.text = info.className + "\n" + info.place
            block.textColor = UIColor.white
            block.textAlignment = .center
            block.font = UIFont(name: "HelveticaNeue", size: fontSize)
            block.lineBreakMode = .byWordWrapping
            block.numberOfLines = 0
            var a = CurriculumView.BLOCK_COLORS[(info.className.utf16.count + info.className.utf8.count * 2) % CurriculumView.BLOCK_COLORS.count]
            block.layer.backgroundColor = UIColor(
                red: CGFloat(a[0])/255.0,
                green: CGFloat(a[1])/255.0,
                blue: CGFloat(a[2])/255.0,
                alpha: 1.0).cgColor
            block.layer.cornerRadius = 3
            
            block.root = self
            let place = info.place
                .replaceAll("(单)", "")
                .replaceAll("(双)", "")
            block.info = "课程名称：\(info.className)\n上课地点：\(place)\n上课周次：\(info.startWeek)~\(info.endWeek)周"
            if(info.place.contains("(单)")){block.info += "单周"}
            if(info.place.contains("(双)")){block.info += "双周"}
            block.info += "\(info.weekNum)\n上课时间：\(info.startTime)~\(info.endTime)节 (\(info.getTimePeriod()))\n"
            if let additional = sidebar[info.className] {
                block.info += additional
            } else {
                block.info += "获取教师及学分信息失败，请刷新"
            }
            
            block.isUserInteractionEnabled = true
            let tapStepGestureRecognizer = UITapGestureRecognizer(target: block, action: #selector(CurriculumBlock.showInfo))
            block.addGestureRecognizer(tapStepGestureRecognizer)
            self.view.addSubview(block)
        }
    }
}
