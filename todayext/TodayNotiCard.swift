//
//  CardCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class TodayNotiCard {
    
    static func getRefresher () -> ApiRequest {
        return Cache.cardToday.refresher
    }
    
    static func getNoti() -> String? {
        if !ApiHelper.isLogin() {
            return nil
        }
        
        let cache = Cache.cardToday.value
        let content = JSON.parse(cache)["content"]
        // 获取余额并且设置
        if let extra = Float(content["left"].stringValue.replaceAll(",", "")) {
            return "一卡通余额：\(String(format: "%.2f", extra))元"
        } else {
            return "一卡通数据错误，请刷新"
        }
    }
}
