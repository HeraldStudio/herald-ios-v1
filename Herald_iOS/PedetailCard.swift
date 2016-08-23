//
//  PedetailCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class PedetailCard {
    
    static func getRefresher () -> ApiRequest {
        return Cache.pcForecast.refresher | Cache.peCount.refresher | Cache.peDetail.refresher
    }
    
    static func getCard() -> CardsModel {
        if !ApiHelper.isLogin() {
            return CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "登录即可使用跑操查询、跑操预告功能", priority: .NO_CONTENT)
        }
        
        let date = Cache.pcDate.value
        let forecast = Cache.pcForecast.value
        let record = Cache.peDetail.value
        let count = Int(Cache.peCount.value) ?? 0
        let remain = Int(Cache.peRemain.value) ?? 0
        
        if record == "" {
            return CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "跑操数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let _now = GCalendar()
        let now = _now.hour * 60 + _now.minute
        let startTime = 6 * 60 + 20
        let endTime = 7 * 60 + 20
        
        let todayStamp = String(format: "%4d-%02d-%02d", _now.year, _now.month, _now.day)
        let row = CardsRowModel(pedetailCount: count, remain: remain)
        
        if record.containsString(todayStamp) {
            let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "你今天的跑操已经到账。" + getRemainNotice(count, remain, false), priority: .CONTENT_NOTIFY)
            model.rows.append(row)
            return model
        }
        
        if now >= startTime && date != todayStamp {
            return CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "跑操预告数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        if now < startTime {
            // 跑操时间没到
            let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "小猴会在早上跑操时间实时显示跑操预告\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
            model.rows.append(row)
            return model
        } else if now >= endTime {
            // 跑操时间已过
            if !forecast.containsString("跑操") {
                // 没有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "今天没有跑操预告信息\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            } else {
                // 有跑操预告信息但时间已过
                let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "\(forecast)(已结束)\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            }
        } else {
            // 处于跑操时间
            if !forecast.containsString("跑操") {
                // 还没有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "目前暂无跑操预报信息，过一会再来看吧~\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            } else {
                // 有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: ModulePedetail, desc: "小猴预测\(forecast)\n" + getRemainNotice(count, remain, forecast.containsString("今天正常跑操")), priority: .CONTENT_NOTIFY)
                model.rows.append(row)
                return model
            }
        }
    }
    
    static func getRemainNotice (count : Int, _ remain : Int, _ todayAvailable : Bool) -> String {
        
        if count == 0 {
            return "你这学期还没有跑操，如果是需要跑操的同学要加油咯~"
        }
        if count >= 45 {
            return "已经跑够次数啦，" + (remain > 0 && remain >= 50 - count ?
                "你还可以再继续加餐，多多益善哟~" : "小猴给你个满分~")
        }
        
        let offset = remain - (45 - count)
        if offset >= 20 {
            return "时间似乎比较充裕，但还是要加油哟~"
        } else if offset >= 10 {
            return "时间比较紧迫了，" + (todayAvailable ? "赶紧加油出门跑操吧~" : "还需要继续加油哟~")
        } else if offset >= 0 {
            return "没时间解释了，" + (todayAvailable ? "赶紧出门补齐跑操吧~" : "赶紧找机会补齐跑操吧~")
        } else {
            return "似乎没什么希望了，小猴为你感到难过，不如参加一些加跑操的活动试试？"
        }
    }
}