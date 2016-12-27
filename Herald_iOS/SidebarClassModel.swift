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
    
    var isAdded : Bool {
        let data = Cache.curriculum.value
        
        // 读取json内容
        let content = JSON.parse(data)
        
        for weekNum in WEEK_NUMS {
            let arr = content[weekNum]
            for i in 0 ..< arr.count {
                do {
                    let info = try ClassModel(json: arr[i])
                    if info.className == className {
                        return true
                    }
                } catch {}
            }
        }
        return false
    }
}
