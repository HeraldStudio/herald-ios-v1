/**
 * 单次课程信息的类
 */

import Foundation;
import SwiftyJSON;

class ClassInfo {
    var className, place : String
    var weekNum : String = ""
    var weekDay : Int = 0
    var startWeek, endWeek, startTime, endTime : Int
    
    init (json : JSON) throws {
        className = json[0].stringValue
        place = json[2].stringValue
        let timeStr = json[1].stringValue
        var timeStrs = timeStr
            .replaceAll("]", "-")
            .replaceAll("[", "")
            .replaceAll("周", "")
            .replaceAll("节", "")
            .split("-")
        
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
    
    func isFitEvenOrOdd(weekNum: Int) -> Bool{
        if(weekNum % 2 == 0){
            return !place.containsString("(单)")
        } else {
            return !place.containsString("(双)")
        }
    }
    
    func time60ToHourMinute(time: Int) -> String{
        return String(format: "%d:%02d", time / 60, time % 60)
    }
}