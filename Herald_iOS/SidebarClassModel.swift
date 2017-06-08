import Foundation
import SwiftyJSON

class SidebarClassModel {
    var className : String
    var teacher : String
    var week : String
    var credits : String
    
    init (sidebarJson json : JSON) {
        className = json["course"].string ?? "未知课程"
        teacher = json["lecturer"].string ?? "未知教师"
        credits = json["credit"].string ?? "未知"
        week = json["week"].string ?? "未知"
    }
    
    var desc : String {
        return "\(teacher) \(week)周 \(credits)学分"
    }
}
