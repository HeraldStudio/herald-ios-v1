import Foundation
import SwiftyJSON

class GymRecordModel {
    var orderTime : String
    var useBeginTime : String
    var useEndTime : String
    var useDate : String
    var id : Int
    var itemName : String
    var floorName : String
    var state : Int
    var usePeoples : Int
    
    init (json : JSON) {
        orderTime = json["orderTime"].stringValue
        useBeginTime = json["useBeginTime"].stringValue
        useEndTime = json["useEndTime"].stringValue
        useDate = json["useDate"].stringValue
        id = json["id"].intValue
        itemName = json["itemName"].stringValue
        floorName = json["floorName"].stringValue
        state = json["state"].intValue
        usePeoples = json["usePeoples"].intValue
    }
    
    var stateTip : String {
        if state == 2 {
            return "预约成功"
        } else if state == 3 {
            return "使用中"
        } else if state == 4 {
            return "已结束"
        } else if state == 5 {
            return "失约"
        } else if state == 6 {
            return "已取消"
        }
        return "未知状态"
    }
    
    var title : String {
        return itemName + "馆（\(floorNameTip)）\(usePeoples)人"
    }
    
    var floorNameTip : String {
        if floorName == "" {
            return "无效地点"
        }
        return floorName
    }
    
    var canCancel : Bool {
        return state < 3
    }
    
    var desc : String {
        return useDate + " " + useBeginTime + "-" + useEndTime + (canCancel ? " - 点击取消预约" : "")
    }
}