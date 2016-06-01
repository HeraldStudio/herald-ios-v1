//
//  ExamModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExamModel {
    var course : String
    var time : String
    var location : String
    var hour : String
    var customIndex = -1
    
    var timeAndPlace : String {
        if location == "" {
            return time
        } else {
            return time + " @ " + location
        }
    }
    
    var period : String {
        return hour == "" ? "" : hour + "分钟"
    }
    
    var days : Int {
        let ymd = time.split(" ")[0]
        return (GCalendar(ymd) - GCalendar(.Day)) / 86400
    }
    
    init (json : JSON) throws {
        course = json["course"].stringValue
        time = json["time"].stringValue.split("(")[0]
        location = json["location"].stringValue
        hour = json["hour"].stringValue
    }
}