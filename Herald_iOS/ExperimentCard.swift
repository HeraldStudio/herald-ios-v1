//
//  ExperimentCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * 读取实验缓存，转换成对应的时间轴条目
 **/
class ExperimentCard {
    
    static func getRefresher () -> ApiRequest {
        return ApiSimpleRequest(.Post, checkJson200: true).api("phylab")
            .uuid().toCache("herald_experiment")
    }
    
    static func getCard () -> CardsModel {
        let cache = CacheHelper.get("herald_experiment")
        if cache == "" {
            return CardsModel(cellId: "CardsCellExperiment", module: ModuleExperiment, desc: "实验数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let content = JSON.parse(cache)["content"]
        var todayHasExperiments = false
        // 时间未到的所有实验
        var allExperiments : [CardsRowModel] = []
        // 今天的实验或当前周的实验。若今天无实验，则为当前周的实验
        var currExperiments : [CardsRowModel] = []
        
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
                
                let row = CardsRowModel(experimentModel: ExperimentModel(json: jsonObject))
                
                // 没开始的实验全部单独记录下来
                if then > now {
                    allExperiments.append(row)
                }
                
                // 属于同一周
                if then.year == now.year && then.weekOfYear == now.weekOfYear {
                    // 如果发现今天有实验
                    if then.dayOfWeekFromSunday == now.dayOfWeekFromSunday {
                        // 如果是15分钟之内快要开始的实验，放弃之前所有操作，直接返回这个实验的提醒
                        let nowStamp = now.hour * 60 + now.minute
                        let thenStamp = then.hour * 60 + then.minute
                        if nowStamp < thenStamp && nowStamp >= thenStamp - 15 {
                            let model = CardsModel(cellId: "CardsCellExperiment", module: ModuleExperiment, desc: "你有1个实验即将开始，请注意时间准时参加", priority: .CONTENT_NOTIFY)
                            model.rows.append(row)
                            return model
                        }
                        
                        // 如果是已经开始还未结束的实验，放弃之前所有操作，直接返回这个实验的提醒
                        let endStamp = thenStamp + 3 * 60
                        if nowStamp >= thenStamp && nowStamp < endStamp {
                            let model = CardsModel(cellId: "CardsCellExperiment", module: ModuleExperiment, desc: "1个实验正在进行", priority: .CONTENT_NOTIFY)
                            model.rows.append(row)
                            return model
                        }
                        
                        // 如果这个实验已经结束，跳过它
                        if nowStamp >= endStamp {
                            continue
                        }
                        
                        // 如果是第一次发现今天有实验，则清空列表（之前放在列表里的都不是今天的）
                        // 然后做标记，以后不再记录不是今天的实验
                        if !todayHasExperiments {
                            currExperiments.removeAll()
                            todayHasExperiments = true
                        }
                        
                        // 记录今天的实验
                        currExperiments.append(row)
                    }
                    
                    // 如果不是今天的实验但已经结束，跳过它
                    if then.dayOfWeekFromSunday.rawValue <= now.dayOfWeekFromSunday.rawValue {
                        continue
                    }
                    
                    // 如果至今还未发现今天有实验，则继续记录本周的实验
                    if !todayHasExperiments {
                        currExperiments.append(row)
                    }
                }
            }
        }
        
        // 解析完毕，下面做统计
        let N = currExperiments.count
        let M = allExperiments.count
        
        // 今天和本周均无实验
        if N == 0 {
            let model = CardsModel(cellId: "CardsCellExperiment", module: ModuleExperiment, desc: (M == 0 ? "你没有未完成的实验，" : ("本学期你还有\(M)个实验，"))
                + "实验助手可以智能提醒你参加即将开始的实验", priority: M == 0 ? .NO_CONTENT : .CONTENT_NO_NOTIFY)
            allExperiments = allExperiments.sort {$0.sortOrder < $1.sortOrder}
            model.rows.appendContentsOf(allExperiments)
            return model
        }
        
        // 今天或本周有实验
        let model = CardsModel(cellId: "CardsCellExperiment", module: ModuleExperiment, desc: (todayHasExperiments ? "今天有" : "本周有") + "\(N)个实验，请注意准时参加", priority: .CONTENT_NO_NOTIFY)
        currExperiments = currExperiments.sort {$0.sortOrder < $1.sortOrder}
        model.rows.appendContentsOf(currExperiments)
        return model
    }
}