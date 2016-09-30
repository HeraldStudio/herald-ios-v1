import Foundation

// 有卡片的模块
let ModuleCard = AppModule("cardextra", "一卡通", "提供一卡通消费情况查询、一卡通在线充值以及余额提醒服务", "MODULE_QUERY_CARDEXTRA", "ic_card", true)
let ModulePedetail = AppModule("pedetail", "跑操助手", "提供跑操次数及记录查询、早操预报以及跑操到账提醒服务", "MODULE_QUERY_PEDETAIL", "ic_pedetail", true)
let ModuleCurriculum = AppModule("curriculum", "课表助手", "浏览当前学期的课表信息，并提供上课提醒服务", "MODULE_QUERY_CURRICULUM", "ic_curriculum", true)
let ModuleExperiment =  AppModule("experiment", "实验助手", "浏览当前学期的实验信息，并提供实验提醒服务", "MODULE_QUERY_EXPERIMENT", "ic_experiment", true)
let ModuleExam = AppModule("exam", "考试助手", "查询个人考试安排，提供考试倒计时提醒服务", "MODULE_QUERY_EXAM", "ic_exam", true)
let ModuleLecture = AppModule("lecture", "人文讲座", "查看人文讲座听课记录，并提供人文讲座预告信息", "MODULE_QUERY_LECTURE", "ic_lecture", true)
let ModuleJwc = AppModule("jwc", "教务通知", "显示教务处最新通知，提供重要教务通知提醒服务", "MODULE_QUERY_JWC", "ic_jwc", true)

// 无卡片的模块
let ModuleSeuNet = AppModule("seunet", "校园网络", "显示校园网使用情况及校园网账户余额信息", "MODULE_QUERY_SEUNET", "ic_seunet", false)
let ModuleGymReserve = AppModule("gymreserve", "场馆预约", "提供体育场馆预约和查询服务", "MODULE_GYMRESERVE", "ic_gymreserve", false)
let ModuleLibrary = AppModule("library", "图书馆", "查看图书馆实时借阅排行、已借书籍，并提供图书在线续借服务", "MODULE_QUERY_LIBRARY", "ic_library", false)
let ModuleGrade = AppModule("grade", "成绩查询", "查询历史学期的科目成绩、学分以及绩点详情", "MODULE_QUERY_GRADE", "ic_grade", false)
let ModuleSrtp = AppModule("srtp", "课外研学", "提供SRTP学分及得分详情查询服务", "MODULE_QUERY_SRTP", "ic_srtp", false)
let ModuleSchoolBus = AppModule("schoolbus", "校车助手", "提供可实时更新的校车班车时间表", "MODULE_QUERY_SCHOOLBUS", "ic_bus", false)
//let ModuleExpress = AppModule("express", "快递代取", "提供线上预订、线下交付的快递便捷代取服务", "MODULE_EXPRESS", "ic_express", false)
let ModuleSchedule = AppModule("schedule", "校历查询 Web", "显示当前年度各学期的学校校历安排", "http://heraldstudio.com/static/images/xiaoli.jpg", "ic_schedule", false)
let ModuleQuanYi = AppModule("quanyi", "权益服务 Web", "向东大校会权益部反馈投诉信息", "https://jinshuju.net/f/By3aTK", "ic_quanyi", false)
let ModuleEmptyRoom = AppModule("emptyroom", "空教室 Web", "提供指定时间内的空教室信息查询服务", "http://www.heraldstudio.com/queryEmptyClassrooms/m", "ic_emptyroom", false)

// 特殊的模块，模块管理
let ModuleManager = AppModule("", "模块管理", "管理各模块的显示/隐藏状态", "MODULE_MANAGER", "ic_add", true)

let Modules = [
    ModuleCard, ModulePedetail, ModuleCurriculum, ModuleExperiment, ModuleExam, ModuleLecture, ModuleJwc, ModuleSeuNet, ModuleGymReserve, ModuleLibrary, ModuleGrade, ModuleSrtp, ModuleSchoolBus, /*ModuleExpress, */ModuleSchedule, ModuleQuanYi, ModuleEmptyRoom
]