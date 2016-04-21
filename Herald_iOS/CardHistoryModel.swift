//
//  CardHistoryModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class CardHistoryModel {
    var date : String
    var time : String
    var place : String
    var type : String
    var cost : String
    var left : String
    
    init (date : String, time : String, place : String, type : String, cost : String, left : String) {
        self.date = date
        self.time = time
        self.place = place
        self.type = type
        self.cost = cost
        self.left = left
        
        // 银行转账项目的余额显示不正确，隐藏它
        if type == "银行转帐" {
            self.left = ""
        }
        
        // 小字有内容、大字无内容时，把小字放到大字的位置上，小字显示“无详情”
        if place == "" && type != "" {
            self.place = type
            self.type = "无详情"
        }
    }
}