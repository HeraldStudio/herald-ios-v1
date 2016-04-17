//
//  CurriculumView.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/17.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class CurriculumView {
    // 常量，我校一天的课时数
    static let PERIOD_COUNT = 13;

    // 常量，今天所在列与其他列的宽度比值
    static let TODAY_WEIGHT : CGFloat = 1.5;

    // 星期在JSON中的表示值
    static let WEEK_NUMS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    // 星期在屏幕上的显示值
    static let WEEK_NUMS_CN = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

    // 每节课开始的时间，以(Hour * 60 + Minute)形式表示
    // 本程序假定每节课都是45分钟
    static let CLASS_BEGIN_TIME = [
        8 * 60, 8 * 60 + 50, 9 * 60 + 50, 10 * 60 + 40, 11 * 60 + 30,
        14 * 60, 14 * 60 + 50, 15 * 60 + 50, 16 * 60 + 40, 17 * 60 + 30,
        18 * 60 + 30, 19 * 60 + 20, 20 * 60 + 10
    ];

    static let BLOCK_COLORS = [
        [245,98,154],[254,141,63],[236,173,7],[161,210,19],
        [18,202,152],[0,171,212],[109,159,244],[159,115,255]
    ];
}
