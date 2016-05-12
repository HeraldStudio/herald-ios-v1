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
    var timeAndPlace : String
    var periodAndTeacher : String
    var days : Int
    
    init (_ course : String, _ timeAndPlace : String, _ periodAndTeacher : String, _ days : Int) {
        self.course = course
        self.timeAndPlace = timeAndPlace
        self.periodAndTeacher = periodAndTeacher
        self.days = days
    }
    
    convenience init (json : JSON) throws {
        let course = json["course"].stringValue
        let time = json["time"].stringValue.split("(")[0]
        let location = json["location"].stringValue
        let hour = json["hour"].stringValue
        // let teacher = json["teacher"].stringValue
        
        let ymd = time.split(" ")[0].split("-")
        let comp = NSCalendar.currentCalendar()
            .components(NSCalendarUnit(arrayLiteral: .Year, .Month, .Day), fromDate: NSDate())
        
        guard let fromDate = NSCalendar.currentCalendar().dateFromComponents(comp) else { throw E }
        
        guard let year = Int(ymd[0]) else { throw E }
        guard let month = Int(ymd[1]) else { throw E }
        guard let day = Int(ymd[2]) else { throw E }
        
        comp.year = year
        comp.month = month
        comp.day = day
        
        guard let toDate = NSCalendar.currentCalendar().dateFromComponents(comp) else { throw E }
        
        let interval = Int(toDate.timeIntervalSinceDate(fromDate) / 86400)
        
        self.init(course, time + " @ " + location, "\(hour)分钟", interval)
    }
}