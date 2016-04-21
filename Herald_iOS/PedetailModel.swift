//
//  PedetailModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class PedetailModel {
    var year : Int
    var month : Int
    var dates : [Int]
    
    init (year : Int, month : Int, dates : [Int]) {
        self.year = year
        self.month = month
        self.dates = dates
    }
}