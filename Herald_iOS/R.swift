import Foundation

/**
 * R | 表示模块、布局、网络请求等资源的全局常量池
 */
class R {
    /// 模块
    class module {
        static let array = [
            card, pedetail, curriculum, experiment, lecture, jwc, exam,
            seunet, gymreserve, library, grade, srtp, schoolbus, schedule, quanyi, emptyroom//, deskgame
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
        
        // 特殊的模块，模块管理
        static let moduleManager = AppModule(-1, "", "模块管理", "管理各模块的显示/隐藏状态",
                                             "MODULE_MANAGER", "ic_add", true)
    }
    
    class string {
        static let aboutUsText =
            "东南大学小猴偷米工作室，成立于2016年3月，前身为2001年6月成立的东南大学先声网，代表产品有小猴偷米校园服务微信公众号、东南大学最有影响力毕业生投票网站、东南大学机甲帝国智能体平台等等。\n" +
            "\n" +
            "作为东大的一份子，我们致力于为东大学子们提供更好的信息平台，涵盖学习、生活、娱乐的服务。\n" +
            "\n" +
            "作为爱好技术的一群人，我们对新的知识，新的世界，始终保持高涨的热情。\n" +
            "\n" +
            "我们为学生社团、组织和各类积极向上、基于学生的活动提供宣传平台，也为有梦想的你，提供成长的平台。\n" +
            "\n" +
            "不论你是热爱技术、擅长设计、精于文编，还是菜鸟小白，只要有兴趣，我们都欢迎你的加入！"
        static let contactUsText =
            "招新/赞助/合作/活动宣传热线：\n" +
            "梁同学   156-5191-8580\n" +
            "\n" +
            "客户端报障/建议热线：\n" +
            "何同学   187-9588-9958\n" +
            "\n" +
            "简历投递邮箱：\n" +
            "heraldseu@outlook.com"
        static let termsText =
            "本软件在许可范围内使用了如下设计作品：\n" +
            "[CC-BY] monkey by Zille Sophie Bostinius from the Noun Project\n" +
            "小猴偷米工作室对其作者致以诚挚的感谢。\n" +
            "\n" +
            "本软件所有数据来自学校网站或其他第三方，受学校网站或其他第三方数据的不确定性影响，本软件显示的数据可能会出现某些不正常情况，包含但不限于无法连接、信息错误、显示延迟或自相矛盾等。小猴偷米工作室不对以上问题导致的任何后果负责。"
        static let update_url = "https://itunes.apple.com/us/app/xiao-hou-tou-mi/id1107998946"
    }
}