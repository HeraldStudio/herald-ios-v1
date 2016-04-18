//
//  CardHistoryModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class CardHistoryModel {
    var place : String
    var type : String
    var cost : String
    var left : String
    
    init (place : String, type : String, cost : String, left : String) {
        self.place = place
        self.type = type
        self.cost = cost
        self.left = left
    }
}