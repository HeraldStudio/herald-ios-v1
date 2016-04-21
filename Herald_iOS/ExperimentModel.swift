//
//  ExperimentModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class ExperimentModel {
    var name : String
    var timeAndPlace : String
    var teacher : String
    var grade : String
    
    init (_ name : String, _ timeAndPlace : String, _ teacher : String, _ grade : String) {
        self.name = name
        self.timeAndPlace = timeAndPlace
        self.teacher = teacher
        self.grade = grade
    }
}