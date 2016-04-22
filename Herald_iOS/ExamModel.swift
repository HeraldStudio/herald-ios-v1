//
//  ExamModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class ExamModel {
    var course : String
    var timeAndPlace : String
    var periodAndTeacher : String
    var days : Int
    
    init (_ course : String, _ timeAndPlace : String, _ periodAndTeacher : String, _ days : Int) {
        self.course = course
        self.timeAndPlace = timeAndPlace
        self.periodAndTeacher = periodAndTeacher
        self.days = days
    }
}