import Foundation
import SwiftyJSON

class SidebarClassModel {
    var className : String
    var teacher : String
    var startWeek : Int
    var endWeek : Int
    var credits : String
    
    init (sidebarJson json : JSON) {
        className = json["course"].stringValue
        teacher = json["lecturer"].stringValue
        credits = json["credit"].stringValue
        
        startWeek = 0
        endWeek = 0
        
        let weeks = json["week"].stringValue.split("-")
        if weeks.count >= 2 {
            if let s = Int(weeks[0]), e = Int(weeks[1]) {
                startWeek = s
                endWeek = e
            }
        }
    }
    
    var desc : String {
        return "\(teacher) \(startWeek)-\(endWeek)周 \(credits)学分"
    }
    
    var isAdded : Bool {
        let data = Cache.curriculum.value
        
        // 读取json内容
        let content = JSON.parse(data)
        
        for weekNum in CurriculumView.WEEK_NUMS {
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
    
    var strIsAdded : String {
        return isAdded ? "" : "未添加"
    }
}