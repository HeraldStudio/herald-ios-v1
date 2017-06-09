import Foundation
import SwiftyJSON

/// 各模块缓存
class Cache {
    
    // 活动第一页缓存
    static let activity = AppCache("herald_activity") {
        ApiSimpleRequest(.get).url("https://www.heraldstudio.com/herald/api/v1/huodong/get").toCache("herald_activity")
    }
    
    static let activityHot = AppCache("herald_activity_hot") {
        ApiSimpleRequest(.get).url("https://www.heraldstudio.com/herald/api/v1/huodong/get?type=hot").toCache("herald_activity_hot")
    }
    
    // 一卡通模块缓存
    static let card = AppCache("herald_card") {
        ApiSimpleRequest(.post).api("card").uuid().post("timedelta", "31").toCache("herald_card")
    }
    
    static let cardDate = AppCache("herald_card_date")
    
    static let cardToday = AppCache("herald_card_today") {
        ApiSimpleRequest(.post).api("card").uuid().post("timedelta", "1").toCache("herald_card_today")
    }
    
    // 跑操模块缓存
    static let pcForecast = AppCache("herald_pc_forecast") {
        ApiSimpleRequest(.post).api("pc")
            .uuid().toCache("herald_pc_forecast") { json in json["content"] }
            .onResponse { success, code, _ in
                let todayComp = GCalendar(.Day)
                let today = String(format: "%4d-%02d-%02d", todayComp.year, todayComp.month, todayComp.day)
                if success {
                    Cache.pcDate.value = today
                } else if code == 201 {
                    Cache.pcDate.value = today
                    CacheHelper.set("herald_pc_forecast", "refreshing")
                }
        }
    }
    
    static let pcDate = AppCache("herald_pc_date")
    
    static let peCount = AppCache("herald_pe_count") {
        ApiSimpleRequest(.post).api("pe").uuid()
            .toCache("herald_pe_count") { json in json["content"] }
            .toCache("herald_pe_remain") { json in json["remain"] }
    }
    
    static let peRemain = AppCache("herald_pe_remain")
    
    static let peDetail = AppCache("herald_pedetail") {
        ApiSimpleRequest(.post).api("pedetail")
            .uuid().toCache("herald_pedetail") {
                json in if !json.rawStringValue.contains("[") { throw E }
                return json
        }
    }
    
    // 课表模块缓存
    static let curriculum = AppCache("herald_curriculum") {
        ApiSimpleRequest(.post).api("curriculum").uuid().toCache("herald_curriculum")
    }.masked { oldValue in
        if curriculumAdvance.value == "1" {
            var json = JSON.parse(oldValue)
            if json["term"].stringValue.hasSuffix("-2"){ // 仅秋季学期有效
                // 读取开学日期
                let startMonth = json["content"]["startdate"]["month"].intValue
                let startDate = json["content"]["startdate"]["day"].intValue
                
                // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
                let cal = GCalendar(.Day)
                let nowDate = GCalendar(.Day)
                cal.month = startMonth + 1
                cal.day = startDate
                
                // 如果开学日期比今天晚了超过两个月，则认为是去年开学的。这里用while保证了thisWeek永远大于零
                while (cal - nowDate > 60 * 86400) {
                    cal.year -= 1
                }
                
                cal -= 28 * 24 * 60 * 60
                json["content"]["startdate"]["month"] = JSON(cal.month - 1)
                json["content"]["startdate"]["day"] = JSON(cal.day)
                return json.rawStringValue
            }
        }
        return oldValue
    }
    
    static let curriculumAdvance = AppCache("herald_curriculum_advance")
    
    static let curriculumTerm = AppCache("herald_term") {
        ApiSimpleRequest(.post).api("term").uuid().toCache("herald_term") { json in json["content"] }
    }
    
    // 实验模块缓存
    static let experiment = AppCache("herald_experiment") {
        ApiSimpleRequest(.post).api("phylab").uuid().toCache("herald_experiment")
    }
    
    // 考试模块缓存
    static let exam = AppCache("herald_exam") {
        ApiSimpleRequest(.post).api("exam").uuid().toCache("herald_exam")
    }
    
    static let examCustom = AppCache("herald_exam_custom")
    
    // 人文讲座缓存
    static let lectureNotices = AppCache("herald_lecture_notices") {
        ApiSimpleRequest(.post).url(ApiHelper.wechat_lecture_notice_url).uuid().toCache("herald_lecture_notices")
    }
    
    static let lectureRecords = AppCache("herald_lecture_records") {
        ApiSimpleRequest(.post).api("lecture").uuid().toCache("herald_lecture_records")
    }
    
    // 教务通知缓存
    static let jwc = AppCache("herald_jwc") {
        ApiSimpleRequest(.post).api("jwc").uuid().toCache("herald_jwc")
    }
    
    // 校园网络缓存
    static let seunet = AppCache("herald_nic") {
        ApiSimpleRequest(.post).api("nic").uuid().toCache("herald_nic")
    }
    
    // 场馆预约缓存
    static let gymReserveGetDate = AppCache("herald_gymreserve_timelist_and_itemlist") {
        ApiSimpleRequest(.post).api("yuyue").uuid().post("method", "getDate").toCache("herald_gymreserve_timelist_and_itemlist")
    }
    
    static let gymReserveMyOrder = AppCache("herald_gymreserve_myorder") {
        ApiSimpleRequest(.post).api("yuyue").uuid().post("method", "myOrder").toCache("herald_gymreserve_myorder")
    }
    
    static let gymReserveGetPhone = AppCache("herald_gymreserve_phone") {
        ApiSimpleRequest(.post).api("yuyue").uuid().post("method", "getPhone").toCache("herald_gymreserve_phone") { json in json["content"]["phone"] }
    }
    
    static let gymReserveUserId = AppCache("herald_gymreserve_userid") {
        ApiSimpleRequest(.post).api("yuyue").uuid().post("method", "getFriendList")
            .post("cardNo", ApiHelper.currentUser.userName)
            .toCache("herald_gymreserve_userid") { json in json["content"][0]["userId"] }
    }
    
    static let gymReserveFriend = AppCache("herald_gymreserve_friend")
    
    // 图书馆模块缓存
    static let libraryBorrowBook = AppCache("herald_library_borrowbook") {
        ApiSimpleRequest(.post).api("library").uuid().toCache("herald_library_borrowbook")
    }
    
    static let libraryHotBook = AppCache("herald_library_hotbook") {
        ApiSimpleRequest(.post).api("library_hot").uuid().toCache("herald_library_hotbook")
    }
    
    // 成绩模块缓存
    static let grade = AppCache("herald_grade_gpa") {
        ApiSimpleRequest(.post).api("gpa").uuid().toCache("herald_grade_gpa")
    }
    
    // 课外研学模块缓存
    static let srtp = AppCache("herald_srtp") {
        ApiSimpleRequest(.post).api("srtp").uuid().post("schoolnum", ApiHelper.currentUser.schoolNum).toCache("herald_srtp")
    }
    
    // 校车助手缓存
    static let schoolbus = AppCache("herald_schoolbus") {
        ApiSimpleRequest(.post).api("schoolbus").uuid().toCache("herald_schoolbus")
    }
    
    static let version = AppCache("herald_version")
}
