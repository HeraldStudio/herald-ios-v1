//
//  CardsRowModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

/// 首页卡片每一行（代表卡片头部或卡片中的一格）通用的模型
class CardsRowModel {
    
    /// 卡片头部的模块图标，用资源id表示
    var icon : String?
    
    /// 卡片头部的模块名称，以及课表、实验、考试、讲座、通知的大标题
    var title : String?
    
    /// 课表、实验的授课教师，考试的时长，讲座的主讲人
    var subtitle : String?
    
    /// 卡片头部的内容，课表、实验、考试、讲座的时间地点，通知的发布日期
    var desc : String?
    
    /// 考试的倒计时天数、跑操的已跑次数
    var count1 : String?
    
    /// 跑操的剩余次数
    var count2 : String?
    
    /// 跑操的剩余天数
    var count3 : String?
    
    /// 某些情况下用来排序的标记
    var sortOrder : Int = 0
    
    init () {}
    
    init (classInfo : ClassInfo, teacher: String) {
        self.title = classInfo.className
        self.subtitle = teacher
        let time = classInfo.getTimePeriod()
        let place = classInfo.place
            .replaceAll("(单)", "")
            .replaceAll("(双)", "")
        self.desc = time + " @ " + place
    }
    
    init (experimentModel : ExperimentModel) {
        self.title = experimentModel.name
        self.subtitle = experimentModel.teacher
        self.desc = experimentModel.timeAndPlace
        let ymdStr = desc!.split("日")[0].replaceAll("年", "-").replaceAll("月", "-").split("-")
        guard let year = Int(ymdStr[0]) else { return }
        guard let month = Int(ymdStr[1]) else { return }
        guard let day = Int(ymdStr[2]) else { return }
        self.sortOrder = ((year * 100) + month) * 100 + day
    }
    
    init (examModel : ExamModel) {
        self.title = examModel.course
        self.subtitle = examModel.periodAndTeacher
        self.desc = examModel.timeAndPlace
        self.count1 = "\(examModel.days)天"
    }
    
    init (lectureModel : LectureModel) {
        self.title = lectureModel.topic
        self.subtitle = lectureModel.speaker
        self.desc = lectureModel.dateAndPlace
    }
}