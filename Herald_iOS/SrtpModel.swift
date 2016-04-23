//
//  SrtpModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class SrtpModel {
    var time : String
    var title : String
    var department : String
    var type : String
    var proportion : String
    var score : String
    
    init (_ time : String, _ title : String, _ department : String, _ type : String, _ proportion : String, _ score : String) {
        self.time = time
        self.title = title
        self.department = department
        self.type = type
        self.proportion = proportion
        self.score = score
    }
}