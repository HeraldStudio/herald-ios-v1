import SwiftyJSON

/// 可以获取开学日期替换配置，并可以获取当前开学日期的类。
// 由于部分学院开学日期与其他学院不同，故设置自定义开学日期的功能。这种功能有很多种实现，但考虑以下两种情况：
//
// 1. 如果只是保存一个自定义的开学日期，让课表助手每次都从这里面取开学日期，那么当学期变化的时候，自定义的
//    开学日期不会自动失效，这不符合用户预期；
// 2. 为了解决上一种情况，考虑当课表数据变化时，自定义的开学日期自动失效。但当学期没变的时候，课表数据也会
//    因为网络问题发生变化，自定义的开学日期很容易突然失效，这也不符合用户预期；
// 
// 为了解决以上两种情况，有一个比较好的实现：保存一个替换前的开学日期，再保存一个用户自定义的开学日期。一旦
// 发现开学日期和替换前的相同，就自动取自定义的开学日期来替换。

class BeginOfTermProvider {
    
    /// 表示一个开学日期的结构
    struct BeginOfTerm {
        var month : Int
        var date : Int
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        init (json : JSON) {
            self.month = json["month"].intValue + 1
            self.date = json["day"].intValue
        }
        
        var cal : GCalendar {
            let today = GCalendar(.Day)
            let beginOfTerm = GCalendar(.Day)
            
            // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
            beginOfTerm.month = month + 1
            beginOfTerm.day = date
            
            // 如果开学日期比今天晚了超过两个月，则认为是去年开学的。这里用while保证了thisWeek永远大于零
            while (beginOfTerm - today > 60 * 86400) {
                beginOfTerm.year -= 1
            }
            return beginOfTerm
        }
    }
    
    /// 获取未经用户设置的原始开学日期
    static var originalBeginOfTerm : BeginOfTerm {
        return BeginOfTerm(json: JSON.parse(Cache.curriculum.value)["startdate"])
    }
}