//
//  ExperimentCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class TodayNotiExperiment {
    
    static func getNoti () -> String? {
        if !ApiHelper.isLogin() {
            return nil
        }
        if Cache.experiment.isEmpty {
            return nil
        }
        
        let cache = Cache.experiment.value
        
        let content = JSON.parse(cache)["content"]
        // 今天的实验或当前周的实验。若今天无实验，则为当前周的实验
        var currExperiments : [ExperimentModel] = []
        
        for section in content {
            let array = section.1
            if array.count == 0 {
                continue
            }
            
            //如果有实验则加载数据和子项布局
            for jsonObject in array.arrayValue {
                let date = jsonObject["Date"].stringValue
                let ymdStr = date.split("日")[0]
                    .replaceAll("年", "-")
                    .replaceAll("月", "-")
                    .split("-")
                let ymd = [Int(ymdStr[0]), Int(ymdStr[1]), Int(ymdStr[2])]
                guard let year = ymd[0] else { continue }
                guard let month = ymd[1] else { continue }
                guard let day = ymd[2] else { continue }
                
                let now = GCalendar()
                let then = GCalendar(year, month, day)
                
                switch jsonObject["Day"].stringValue {
                case "上午": (then.hour, then.minute) = (9, 45)
                case "下午": (then.hour, then.minute) = (13, 45)
                default: (then.hour, then.minute) = (18, 15)
                }
                
                let model = ExperimentModel(json: jsonObject)
                
                // 属于同一周
                if then.year == now.year && then.weekOfYear == now.weekOfYear {
                    // 如果发现今天有实验
                    if then.dayOfWeekFromSunday == now.dayOfWeekFromSunday {
                        // 如果是15分钟之内快要开始的实验，放弃之前所有操作，直接返回这个实验的提醒
                        let nowStamp = now.hour * 60 + now.minute
                        let thenStamp = then.hour * 60 + then.minute
                        if nowStamp < thenStamp && nowStamp >= thenStamp - 15 {
                            return "即将开始实验：" + model.name + " @ " + model.place
                        }
                        
                        // 如果是已经开始还未结束的实验，放弃之前所有操作，直接返回这个实验的提醒
                        let endStamp = thenStamp + 3 * 60
                        if nowStamp >= thenStamp && nowStamp < endStamp {
                            return "正在实验：" + model.name + " @ " + model.place
                        }
                        
                        // 如果这个实验已经结束，跳过它
                        if nowStamp >= endStamp {
                            continue
                        }
                        
                        // 记录今天的实验
                        currExperiments.append(model)
                    }
                    
                    // 如果不是今天的实验但已经结束，跳过它
                    if then.dayOfWeekFromSunday.rawValue <= now.dayOfWeekFromSunday.rawValue {
                        continue
                    }
                }
            }
        }
        
        if currExperiments.count > 0 {
            let model = currExperiments[0]
            return "今天" + model.day + "有实验：" + model.name
        }
        
        return nil
    }
}
