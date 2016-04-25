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
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().api("pc").uuid().toCache("herald_pc_forecast") {
                json -> String in
                guard let str = json["content"].rawString() else {return ""}
                return str
            }.onFinish { success, code, _ in
                let todayComp = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
                let today = String(format: "%4d-%02d-%02d", todayComp.year, todayComp.month, todayComp.day)
                if success {
                    CacheHelper.set("herald_pc_date", cacheValue: today)
                } else if code == 201 {
                    CacheHelper.set("herald_pc_date", cacheValue: today)
                    CacheHelper.set("herald_pc_forecast", cacheValue: "refreshing")
                }
            },
                ApiRequest().api("pe").uuid().toCache("herald_pe_count") {
                    json -> String in
                    guard let str = json["content"].rawString() else {return ""}
                    return str
                    }.toCache("herald_pe_remain") {
                        json -> String in
                        guard let str = json["remain"].rawString() else {return ""}
                        return str
            },
                ApiRequest().api("pedetail").uuid().toCache("herald_pedetail") {
                    json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
            }]
    }
    
    static func getCard() -> CardsModel {
        let date = CacheHelper.get("herald_pc_date")
        let forecast = CacheHelper.get("herald_pc_forecast")
        let record = CacheHelper.get("herald_pedetail")
        let _count = Int(CacheHelper.get("herald_pe_count"))
        let count = _count != nil ? _count! : 0
        let _remain = Int(CacheHelper.get("herald_pe_remain"))
        let remain = _remain != nil ? _remain! : 0
        
        let _now = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        let now = _now.hour * 60 + _now.minute
        let startTime = 6 * 60 + 20
        let endTime = 7 * 60 + 20
        
        let todayStamp = String(format: "%4d-%02d-%02d", _now.year, _now.month, _now.day)
        let row = CardsRowModel(pedetailCount: count, remain: remain)
        
        if record.containsString(todayStamp) {
            let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "你今天的跑操已经到账。" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
            model.rows.append(row)
            return model
        }
        
        if now >= startTime && date != todayStamp {
            return CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "跑操预告加载失败，请手动刷新", priority: .NO_CONTENT)
        }
        
        if now < startTime {
            // 跑操时间没到
            let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "小猴会在早上跑操时间实时显示跑操预告\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
            model.rows.append(row)
            return model
        } else if now >= endTime {
            // 跑操时间已过
            if !forecast.containsString("跑操") {
                // 没有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "今天没有跑操预告信息\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            } else {
                // 有跑操预告信息但时间已过
                let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "\(forecast)(已结束)\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            }
        } else {
            // 处于跑操时间
            if !forecast.containsString("跑操") {
                // 还没有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "目前暂无跑操预报信息，过一会再来看吧~\n" + getRemainNotice(count, remain, false), priority: .CONTENT_NO_NOTIFY)
                model.rows.append(row)
                return model
            } else {
                // 有跑操预告信息
                let model = CardsModel(cellId: "CardsCellPedetail", module: .Pedetail, desc: "小猴预测\(forecast)\n" + getRemainNotice(count, remain, forecast.containsString("今天正常跑操")), priority: .CONTENT_NOTIFY)
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
        let ratio = Float(remain) / Float(45 - count)
        if ratio >= 1.5 {
            return "时间似乎比较充裕，但还是要加油哟~"
        } else if ratio >= 1.2 {
            return "时间比较紧迫了，" + (todayAvailable ? "赶紧加油出门跑操吧~" : "还需要继续锻炼哟~")
        } else if ratio >= 1 {
            return "时间紧任务重，" + (todayAvailable ? "没时间解释了，赶紧出门补齐跑操吧~" : "赶紧找机会补齐跑操吧~")
        } else {
            return "似乎没什么希望了，小猴为你感到难过，不如参加一些加跑操的活动试试？"
        }
    }
}