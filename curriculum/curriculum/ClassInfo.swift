/**
* 单次课程信息的类
*/

import Foundation;
import SwiftyJSON;

class ClassInfo {
    var className, place : String;
    var weekNum : String = "";
    var startWeek, endWeek, startTime, endTime : Int;
    
    init (json : JSON){
        className = json[0].string!;
        place = json[2].string!;
        let timeStr = json[1].string!;
        var timeStrs = timeStr
            .stringByReplacingOccurrencesOfString("]", withString: "-")
            .stringByReplacingOccurrencesOfString("[", withString: "")
            .stringByReplacingOccurrencesOfString("周", withString: "")
            .stringByReplacingOccurrencesOfString("节", withString: "")
            .componentsSeparatedByString("-");
        startWeek = Int(timeStrs[0])!;
        endWeek = Int(timeStrs[1])!;
        startTime = Int(timeStrs[2])!;
        endTime = Int(timeStrs[3])!;
    }
    
    func getTimePeriod() -> String {
        return time60ToHourMinute(CLASS_BEGIN_TIME[startTime - 1]) + "~"
            + time60ToHourMinute(CLASS_BEGIN_TIME[endTime - 1] + 45);
    }
    
    func getPeriodCount() -> Int {
        return endTime - startTime + 1;
    }
    
    func isFitEvenOrOdd(weekNum: Int) -> Bool{
        if(weekNum % 2 == 0){
            return !place.containsString("(单)");
        } else {
            return !place.containsString("(双)");
        }
    }
    
    func time60ToHourMinute(time: Int) -> String{
        let minute = time % 60;
        let hour = time / 60;
        var str = String(hour);
        str += ":";
        if(minute < 10){ str += "0"; }
        str += String(minute);
        return str;
    }
    
    
}