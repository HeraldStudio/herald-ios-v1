//
//  NotificationModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/6.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation

class NotificationModel {
    var tip : String
    var title : String
    var desc : String
    
    init (_ tip : String, _ title : String, _ desc : String) {
        self.tip = tip
        self.title = title
        self.desc = desc
    }
}