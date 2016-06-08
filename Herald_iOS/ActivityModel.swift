import SwiftyJSON

/**
 * ActivityModel | 活动版块列表项模型
 * 此处为了良好的可重用性，成员变量与 JSON 原始数据相对应，
 * 而某些无法直接使用 JSON 原始数据的目标数据是通过 set/get var 来间接获取的
 */
class ActivityModel {
    
    /// {@json title} 活动标题
    var title : String
    
    /// {@json introduction} 活动简介
    var intro : String
    
    /// {@json start_time} 活动开始时间，用于判断一个活动是否开始，不展示给用户
    var startTime : String
    
    /// {@json end_time} 活动结束时间，用于判断一个活动是否结束，不展示给用户
    var endTime : String
    
    /// {@json activity_time} 活动具体时间，用于向用户展示活动实际的进行时间
    var activityTime : String
    
    /// {@json detail_url} 活动详情的页面地址
    var detailUrl : String
    
    /// {@json pic_url} 活动配图地址
    var picUrl : String
    
    /// {@json association} 活动所属组织
    var assoc : String
    
    /// {@json location} 活动地点
    var location : String
    
    /// JSON 构造函数
    init (_ json : JSON) {
        title = json["title"].stringValue
        intro = json["introduction"].stringValue
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        activityTime = json["activity_time"].stringValue
        detailUrl = json["detail_url"].stringValue
        picUrl = json["pic_url"].stringValue
        assoc = json["association"].stringValue
        location = json["location"].stringValue
    }
    
    /// 活动状态的枚举类，以 String 为值，便于直接显示
    enum ActivityState : String {
        case Coming = "即将开始"
        case Going = "进行中"
        case Gone = "已结束"
    }
    
    /// 开始时间，用 GCalendar 表示
    var start : GCalendar {
        return GCalendar(startTime)
    }
    
    /// 结束时间，用 GCalendar 表示
    var end : GCalendar {
        return GCalendar(endTime)
    }
    
    /// 活动状态，用枚举表示
    var state : ActivityState {
        let now = GCalendar(.Day)
        if now < start {
            return .Coming
        }
        if now <= end {
            return .Going
        }
        if now > end {
            return .Gone
        }
        return .Gone
    }
}