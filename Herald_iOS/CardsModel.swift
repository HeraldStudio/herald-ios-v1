//
//  CardsModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

// 消息是否重要，不重要的消息总在后面
enum Priority {
    case CONTENT_NOTIFY
    case CONTENT_NO_NOTIFY
    case NO_CONTENT
}

class CardsModel {
    var attachedView : [UIView] = []
    var vertical = false
    var module : AppModule
    var message : String
    var summary : String
    var priority : Priority
    
    init (_ module: AppModule, _ summary: String, _ message: String, _ priority: Priority) {
        self.module = module
        self.summary = summary
        self.message = message
        self.priority = priority
    }
}