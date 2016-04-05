//
//  Curriculum.swift
//  TestNavigation
//
//  Created by Howie on 16/4/3.
//  Copyright © 2016年 Howie. All rights reserved.
//

import Foundation

////课表

class SideBar: NSObject, NSCoding {
    var lecturer:String
    var course:String
    var week:String
    var credit:String
    //var time:String
    //var location:String
    
    init(lecturer:String,course:String,week:String,credit:String/*,time:String,location:String*/){
        self.lecturer = lecturer
        self.course = course
        self.week = week
        self.credit = credit
        //self.time = time
        //self.location = location
    }
    
    required init(coder aDecoder: NSCoder) {
        lecturer = aDecoder.decodeObjectForKey("lecturer") as! String
        course = aDecoder.decodeObjectForKey("course") as! String
        week = aDecoder.decodeObjectForKey("week") as! String
        credit = aDecoder.decodeObjectForKey("credit") as! String
        //time = aDecoder.decodeObjectForKey("time") as! String
        //location = aDecoder.decodeObjectForKey("location") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(lecturer, forKey: "lecturer")
        aCoder.encodeObject(course, forKey: "course")
        aCoder.encodeObject(week, forKey: "week")
        aCoder.encodeObject(credit, forKey: "credit")
        //aCoder.encodeObject(time, forKey: "time")
        //aCoder.encodeObject(location, forKey: "location")
    }
}