/**
 * 单次课程信息的类
 */

import Foundation;
import SwiftyJSON;

class ClassModel {
    var className, place : String
    var weekNum : String = ""
    var weekDay : Int = 0
    var startWeek, endWeek, startTime, endTime : Int
    
    init (json : JSON) throws {
        if json.count < 3 {
            throw E
        }
        
        className = json[0].stringValue
        place = json[2].stringValue
        let timeStr = json[1].stringValue
        var timeStrs = timeStr
            .replaceAll("]", "-")
            .replaceAll("[", "")
            .replaceAll("周", "")
            .replaceAll("节", "")
            .split("-")
        
        if timeStrs.count < 4 {
            throw E
        }
        
        if let k = Int(timeStrs[0]) {
            startWeek = k
        } else {throw E}
        
        if let k = Int(timeStrs[1]) {
            endWeek = k
        } else {throw E}
        
        if let k = Int(timeStrs[2]) {
            startTime = k
        } else {throw E}
        
        if let k = Int(timeStrs[3]) {
            endTime = k
        } else {throw E}
    }
    
    func getTimePeriod() -> String {
        return time60ToHourMinute(CurriculumView.CLASS_BEGIN_TIME[startTime - 1]) + "~"
            + time60ToHourMinute(CurriculumView.CLASS_BEGIN_TIME[endTime - 1] + 45)
    }
    
    func getPeriodCount() -> Int {
        return endTime - startTime + 1
    }
    
    func isFitEvenOrOdd(_ weekNum: Int) -> Bool{
        if(weekNum % 2 == 0){
            return !place.contains("(单)")
        } else {
            return !place.contains("(双)")
        }
    }
    
    func time60ToHourMinute(_ time: Int) -> String{
        return String(format: "%d:%02d", time / 60, time % 60)
    }
    
    var weekSummary : String {
        var summary = "\(startWeek)~\(endWeek)周"
        if place.contains("(单)") {
            summary += "单周"
        }
        if place.contains("(双)") {
            summary += "双周"
        }
        return summary
    }
}
