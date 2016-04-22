//
//  GradeModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class GradeModel {
    var course : String
    var desc : String
    var score : String
    
    init (_ course : String, _ desc : String, _ score : String) {
        self.course = course
        self.desc = desc
        self.score = score
    }
}