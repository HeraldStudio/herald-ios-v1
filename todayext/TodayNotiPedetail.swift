//
//  PedetailCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class TodayNotiPedetail {
    
    static func getRefresher () -> ApiRequest {
        return Cache.peCount.refresher | Cache.pcForecast.refresher
    }
    
    static func getNoti() -> String? {
        if !ApiHelper.isLogin() {
            return nil
        }
        
        let date = Cache.pcDate.value
        let forecast = Cache.pcForecast.value
        
        let exerciseStatus = ExerciseUtil.getCurrentExerciseStatus()
        let today = GCalendar(.Day)
        let todayStamp = String(format: "%4d-%02d-%02d", today.year, today.month, today.day)
        
        if exerciseStatus == .DuringExercise {
            // 处于跑操时间
            if date != todayStamp {
                return "跑操预告数据为空，请尝试刷新"
            } else if !forecast.contains("跑操") {
                return "目前暂无跑操预报信息"
            } else {
                return "跑操预告：\(forecast)\n"
            }
        }
        
        let record = Cache.peDetail.value
        let count = Int(Cache.peCount.value) ?? -1
        
        if record == "" || count == -1 {
            return "跑操次数数据错误，请刷新"
        }
        
        if count == 0 {
            return "没有跑操记录"
        }
        
        return "跑操次数：\(count) 次"
    }
}
