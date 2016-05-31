import Foundation

/**
 * R | 表示模块、布局、网络请求等资源的全局常量池
 */
class R {
    /// 模块
    class module {
        static let array = [
            card, pedetail, curriculum, experiment, lecture, jwc, exam,
            seunet, gymreserve, library, grade, srtp, schoolbus, schedule, quanyi, emptyroom
        ]
        
        // 有卡片的模块
        static let card = AppModule(0, "cardextra", "一卡通", "提供一卡通消费情况查询、一卡通在线充值以及余额提醒服务", "MODULE_QUERY_CARDEXTRA", "ic_card", true)
        static let pedetail = AppModule(1, "pedetail", "跑操助手", "提供跑操次数及记录查询、早操预报以及跑操到账提醒服务", "MODULE_QUERY_PEDETAIL", "ic_pedetail", true)
        static let curriculum = AppModule(2, "curriculum", "课表助手", "浏览当前学期的课表信息，并提供上课提醒服务", "MODULE_QUERY_CURRICULUM", "ic_curriculum", true)
        static let experiment =  AppModule(3, "experiment", "实验助手", "浏览当前学期的实验信息，并提供实验提醒服务", "MODULE_QUERY_EXPERIMENT", "ic_experiment", true)
        static let lecture = AppModule(4, "lecture", "人文讲座", "查看人文讲座听课记录，并提供人文讲座预告信息", "MODULE_QUERY_LECTURE", "ic_lecture", true)
        static let jwc = AppModule(5, "jwc", "教务通知", "显示教务处最新通知，提供重要教务通知提醒服务", "MODULE_QUERY_JWC", "ic_jwc", true)
        static let exam = AppModule(6, "exam", "考试助手", "查询个人考试安排，提供考试倒计时提醒服务", "MODULE_QUERY_EXAM", "ic_exam", true)
    
        // 无卡片的模块
        static let seunet = AppModule(7, "seunet", "校园网络", "显示校园网使用情况及校园网账户余额信息", "MODULE_QUERY_SEUNET", "ic_seunet", false)
        static let gymreserve = AppModule(8, "gymreserve", "场馆预约", "提供体育场馆预约和查询服务", "MODULE_GYMRESERVE", "ic_gymreserve", false)
        static let library = AppModule(9, "library", "图书馆", "查看图书馆实时借阅排行、已借书籍，并提供图书在线续借服务", "MODULE_QUERY_LIBRARY", "ic_library", false)
        static let grade = AppModule(10, "grade", "成绩查询", "查询历史学期的科目成绩、学分以及绩点详情", "MODULE_QUERY_GRADE", "ic_grade", false)
        static let srtp = AppModule(11, "srtp", "课外研学", "提供SRTP学分及得分详情查询服务", "MODULE_QUERY_SRTP", "ic_srtp", false)
        static let schoolbus = AppModule(12, "schoolbus", "校车助手", "提供可实时更新的校车班车时间表", "MODULE_QUERY_SCHOOLBUS", "ic_bus", false)
        static let schedule = AppModule(13, "schedule", "校历查询 Web", "显示当前年度各学期的学校校历安排", "http://heraldstudio.com/static/images/xiaoli.jpg", "ic_schedule", false)
        static let quanyi = AppModule(14, "quanyi", "权益服务 Web", "向东大校会权益部反馈投诉信息", "https://jinshuju.net/f/By3aTK", "ic_quanyi", false)
        static let emptyroom = AppModule(15, "emptyroom", "空教室 Web", "提供指定时间内的空教室信息查询服务", "http://115.28.27.150/queryEmptyClassrooms/m", "ic_emptyroom", false)
        //static let deskgame = AppModule(16, "deskgame", "桌游助手", "方便大家娱乐的小猴桌游发牌器", "MODULE_DESKGAME", "ic_emptyroom", false)
    }
}