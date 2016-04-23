//
//  SchoolbusModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class SchoolbusModel {
    var time : String
    var desc : String
    var now : Bool
    
    init (_ time : String, _ desc : String, _ now : Bool) {
        self.time = time
        self.desc = desc
        self.now = now
    }
}