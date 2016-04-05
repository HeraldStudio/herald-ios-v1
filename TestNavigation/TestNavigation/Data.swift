//
//  Data.swift
//  TestNavigation
//
//  Created by Howie on 16/3/30.
//  Copyright © 2016年 Howie. All rights reserved.
//

import Foundation

//页面是否需要刷新
var NEED_RELOAD_VIEW = false

let WIDTH = UIScreen.mainScreen().bounds.width
let HEIGHT = UIScreen.mainScreen().bounds.height

let ITEM_WIDTH = CGFloat((WIDTH - 10)/5)
let ITEM_HEIGHT = CGFloat(HEIGHT + 17 / 9)

//讲座数
var LECTURE = 0
//今日课程数
var curriculum = [["上课时间：8:00~9:00","概率论与数理统计(A)","地点：九龙湖教六-303","教师：李翠萍"],
        ["上课时间：9:50~12:15","运筹学","地点：九龙湖教一-204","教师：李翠萍"],
["上课时间：14:00~15:15","JSJMj健身健美","地点：体育馆4号附馆一楼健美房","教师：刘龙柱"]]

//今日跑操
var doOrNot = true

//今日实验
var experi = [Array<String>]()

//今日讲座
var lecture = [Array<String>]()

//今日教务通知
var jwc = [["2015-2016-3学期期中考试查询通知","发布时间：2016-03-29"]]

//自定义蓝色
let selfcolor = UIColor(red: 67/255, green: 151/255, blue: 196/255, alpha: 1)

//请求参数类型
enum jsonPara {
    case card
    case jwc
    case user
    case sideBar
}

//uuid
var uuid = String()

//卡片层数
enum levelLayer {
    case first
    case second
    case third
}

struct dicCard {
    var icon = String()
    var name = String()
    var priority = Int()
    var height = CGFloat()
}

//ModulepageVC显示数据
let moduleDict:Array<Array<String>> = [
    ["ic_card","一卡通","提供一卡通消费情况查询、一卡通在线充值以及余额提醒服务"],
    ["ic_seunet","校园网络","显示校园网使用情况及校园网账户余额信息"],
    ["ic_pedetail","跑操助手","提供跑操次数及记录查询、早操预报以及跑操到账提醒服务"],
    ["ic_curriculum","课表助手","浏览当前学期的课表信息，并提供上课提醒服务"],
    ["ic_library","图书馆","查看图书馆实时借阅排行、已借书籍和馆藏图书搜索"],
    ["ic_experiment","实验助手","浏览当前学期的实验信息，并提供实验提醒服务"],
    ["ic_grade","绩点查询","查询历史学期的科目成绩、学分以及绩点详情"],
    ["ic_srtp","课外研学","提供SRTP学分及得分详情查询服务"],
    ["ic_bus","校车助手","提供可实时更新的校车班车时间表"],
    ["ic_lecture","人文讲座","查看人文讲座记录，并提供人文讲座预告信息"],
    ["ic_jwc","教务通知","显示教务最新通知，提供重要教务通知提醒服务"],
    ["ic_gym","场馆预约","提供体育场馆在线预约和查询服务"],
    ["ic_quanyi","权益服务","向东大校会权益部反馈投诉信息"],
    ["ic_emptyroom","空教室","提供指定时间内的空教室信息查询服务"]]

//Module管理数据开关
var userModuleDict/*:Array<Array<String>>*/ = [["ic_card","一卡通",false,true,true],
    ["ic_seunet","校园网络",true,true,false],
    ["ic_pedetail","跑操助手",false,true,true],
    ["ic_curriculum","课表助手",false,true,true],
    ["ic_library","图书馆",true,true,false],
    ["ic_experiment","实验助手",false,true,true],
    ["ic_grade","绩点查询",true,true,false],
    ["ic_srtp","课外研学",true,true,false],
    ["ic_bus","校车助手",true,true,false],
    ["ic_lecture","人文讲座",false,true,true],
    ["ic_jwc","教务通知",false,true,true],
    ["ic_gym","场馆预约",true,true,false],
    ["ic_quanyi","权益服务",true,true,false],
    ["ic_emptyroom","空教室",true,true,false]]

//默认设置card
let cardModule = [["ic_card","一卡通"],
    ["ic_pedetail","跑操助手"],
    ["ic_curriculum","课表助手"],
    ["ic_experiment","实验助手"],
    ["ic_lecture","人文讲座"],
    ["ic_jwc","教务通知"]]

//用户词典
let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults();

//vie跳转-对应stroboardID字典
var dicVC = ["模块管理":"moduleManagerViewController","课表助手":"curriculumViewController"]

//user字典
var cardJsonDicName = ["date","price","type","system","left"]

var cardLeft = Double()

var cardInfo = [Dictionary<String,String>]()
var cardLeftInfo = Double()
var jwcInfo = [Array<Array<Dictionary<String,String>>>]()
var user = ["sex":"","cardnum":"","name":"朱浩","schoolnum":""]