import Foundation

/**
 * CardsRowModel | 首页卡片行模型
 * 首页卡片每一行（代表卡片头部或卡片中的一格）通用的模型
 */
class CardsRowModel {
    
    /// 卡片头部的模块图标，用资源id表示
    var icon : String?
    
    /// 卡片头部的模块名称，以及课表、实验、考试、讲座、通知的大标题
    var title : String?
    
    /// 课表、实验的授课教师，考试的时长，讲座的主讲人
    var subtitle : String?
    
    /// 卡片头部的内容，课表、实验、考试、讲座的时间地点，通知的发布日期
    var desc : String?
    
    /// 考试的倒计时天数
    var count0 : String?
    
    /// 跑操的已跑次数
    var count1 : String?
    
    /// 跑操的剩余次数
    var count2 : String?
    
    /// 跑操的剩余天数
    var count3 : String?
    
    /// 某些情况下用来排序的标记
    var sortOrder : Int = 0
    
    /// 头部或条目被点击时打开的目标，可以是url，也可以是controller id
    var destination : String = ""
    
    /// 点击时显示的消息，若message和destination都为空，则不响应点击
    var message : String = ""
    
    /// 用一个字符串表示所有内容，用来判断两个卡片是否相等，以便于计算卡片消息是否已读
    var stringValue : String {
        return "|\(icon)|\(title)|\(subtitle)|\(desc)|\(count0)|\(count1)|\(count2)|\(count3)|\(sortOrder)|\(destination)|"
    }
    
    /// 保留默认构造函数，以便构造自定义的模型
    init () {}
    
    /// 从课表模块的原始数据构造一行卡片详情
    init (classModel : ClassModel, teacher: String) {
        self.title = classModel.className
        self.subtitle = teacher
        let time = classModel.getTimePeriod()
        let place = classModel.place
            .replaceAll("(单)", "")
            .replaceAll("(双)", "")
        self.desc = time + " @ " + place
    }
    
    /// 从实验模块的原始数据构造一行卡片详情
    init (experimentModel : ExperimentModel) {
        self.title = experimentModel.name
        self.subtitle = experimentModel.teacher
        self.desc = experimentModel.timeAndPlace
        let ymdStr = desc!.split("日")[0].replaceAll("年", "-").replaceAll("月", "-").split("-")
        guard let year = Int(ymdStr[0]) else { return }
        guard let month = Int(ymdStr[1]) else { return }
        guard let day = Int(ymdStr[2]) else { return }
        self.sortOrder = ((year * 100) + month) * 100 + day
    }
    
    /// 从考试模块的原始数据构造一行卡片详情
    init (examModel : ExamModel) {
        self.title = examModel.course
        self.subtitle = examModel.period
        self.desc = examModel.timeAndPlace
        self.count0 = "\(examModel.days)天"
        self.sortOrder = examModel.days
    }
    
    /// 从人文讲座模块的原始数据构造一行卡片详情
    init (lectureModel : LectureModel) {
        self.title = lectureModel.topic
        self.subtitle = lectureModel.speaker
        self.desc = lectureModel.dateAndPlace
    }
    
    /// 从跑操模块的原始数据构造一行卡片详情
    init (pedetailCount : Int, remain : Int) {
        self.count1 = String(pedetailCount)
        self.count2 = String(max(45 - pedetailCount, 0))
        self.count3 = String(remain)
    }
    
    /// 从教务通知的原始数据构造一行卡片详情
    init (jwcNoticeModel : JwcNoticeModel) {
        self.title = jwcNoticeModel.title
        self.desc = jwcNoticeModel.time
        self.destination = jwcNoticeModel.url
    }
    
    /// 从活动版块的原始数据构造一行卡片详情
    init (activityModel : ActivityModel) {
        self.title = activityModel.title
        self.subtitle = activityModel.state.rawValue
        self.desc = activityModel.activityTime + " @ " + activityModel.location
        self.destination = activityModel.detailUrl
        if destination == "" {
            destination = "TAB1"
        }
    }
}