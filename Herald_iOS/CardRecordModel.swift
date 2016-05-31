import SwiftyJSON

class CardRecordModel {
    var jsonDate : String
    var jsonSystem : String
    var jsonPrice : String
    var jsonType : String
    var jsonLeft : String
    
    init (json : JSON) {
        jsonDate = json["date"].stringValue
        jsonSystem = json["system"].stringValue
        if jsonSystem == "" {
            jsonSystem = json["mail"].stringValue
        }
        jsonPrice = json["price"].stringValue
        jsonType = json["type"].stringValue
        jsonLeft = json["left"].stringValue
    }
    
    var date : String {
        return jsonDate.split(" ")[0]
    }
    
    var displayDate : String {
        if GCalendar(date) == GCalendar(.Day) {
            return "今天"
        }
        if GCalendar(date) == GCalendar(.Day) - 86400 {
            return "昨天"
        }
        if GCalendar(date) == GCalendar(.Day) - 86400 * 2 {
            return "前天"
        }
        return date
    }
    
    var time : String {
        if jsonDate.split(" ").count > 1 {
            return jsonDate.split(" ")[1]
        }
        return ""
    }
    
    var place : String {
        if jsonSystem == "" && jsonType != "" {
            return jsonType
        }
        return jsonSystem
    }
    
    var type : String {
        if jsonSystem == "" && jsonType != "" {
            return "无详情"
        }
        return jsonType
    }
    
    var costNum : Float {
        if let ret = Float(jsonPrice) {
            return ret
        }
        return 0
    }
    
    var cost : String {
        return String(format: "%+.2f", costNum)
    }
    
    var left : String {
        if jsonType == "银行转账" {
            return ""
        }
        return jsonLeft
    }
    
    var leftNum : Float {
        if let ret = Float(jsonLeft) {
            return ret
        }
        return 0
    }
    
    var isConsume : Bool {
        return costNum < 0
    }
}
