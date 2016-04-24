//
//  CardsModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

/// 表示卡片消息是否重要，不重要的消息总在后面
enum Priority : Int {
    /// 具有时效性的内容
    case CONTENT_NOTIFY
    /// 有内容，但不具有时效性
    case CONTENT_NO_NOTIFY
    /// 没有内容
    case NO_CONTENT
}

/// 首页卡片每一个分区（代表一个卡片）的模型，这里只需要用来存储每一行的数据、用来排序、以及用来存储点击卡片时打开的页面
class CardsModel {
    /// 除卡片头部外，其他行所用的资源复用id
    var cellId : String
    /// 每一行的模型（含头部）
    var rows : [CardsRowModel] = []
    /// 该卡片的优先级
    var priority : Priority = .NO_CONTENT
    /// 点击该卡片打开的目标，可以是url，也可以是controller id
    var destination : String = ""
    
    /// 从已有的模块初始化一个卡片
    init (cellId: String, module : Module, desc : String, priority : Priority) {
        self.cellId = cellId
        let appModule = SettingsHelper.MODULES[module.rawValue]
        let header = CardsRowModel()
        header.icon = appModule.icon
        header.title = appModule.nameTip
        header.desc = desc
        rows.append(header)
        self.priority = priority
        self.destination = appModule.controller
    }
    
    /// 用自定义的项目初始化一个卡片
    init (cellId: String, icon : String, title : String, desc : String, dest : String, priority : Priority) {
        self.cellId = cellId
        let header = CardsRowModel()
        header.icon = icon
        header.title = title
        header.desc = desc
        rows.append(header)
        self.priority = priority
        self.destination = dest
    }
}