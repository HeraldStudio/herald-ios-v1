//
//  ExperimentModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExperimentModel {
    var name : String
    var teacher : String
    var grade : String
    var date : String
    var day : String
    var place : String
    
    var time : String {
        return date + day
    }
    
    var timeAndPlace : String {
        return time + " @ " + place
    }
    
    convenience init (json: JSON) {
        let name = json["name"].stringValue
        let date = json["Date"].stringValue
        let day = json["Day"].stringValue
        let place = json["Address"].stringValue
        let teacher = json["Teacher"].stringValue
        
        var grade : String = ""
        if json["Grade"].string != nil {
            grade = json["Grade"].string!
        }
        self.init(name, date, day, place, teacher, grade)
    }
    
    init (_ name : String, _ date: String, _ day: String, _ place : String, _ teacher : String, _ grade : String) {
        self.name = name
        self.date = date
        self.day = day
        self.place = place
        self.teacher = teacher
        self.grade = grade
    }
}
