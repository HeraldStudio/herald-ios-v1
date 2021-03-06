//
//  LectureCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * 读取人文讲座预告缓存，转换成对应的时间轴条目
 **/
class LectureCard {
    
    static func getRefresher () -> ApiRequest {
        return Cache.lectureNotices.refresher
    }
    
    static func getCard() -> CardsModel {
        if Cache.lectureNotices.isEmpty {
            return CardsModel(cellId: "CardsCellLecture", module: ModuleLecture, desc: "人文讲座数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let cache = Cache.lectureNotices.value
        let jsonArray = JSON.parse(cache)["content"]
        var lectures : [CardsRowModel] = []
        
        for lecture in jsonArray.arrayValue {
            let dateStr = lecture["date"].stringValue.split("日")[0]
            let date = dateStr.replaceAll("年", "-").replaceAll("月", "-").split("-")
            let mdStr = [date[date.count - 2], date[date.count - 1]]
            guard let month = Int(mdStr[0]) else { continue }
            guard let day = Int(mdStr[1]) else { continue }
            
            let time = GCalendar()
            if (time.month == month && time.day == day) {
                if (time.hour * 60 + time.minute < 19 * 60) {
                    let row = CardsRowModel(lectureModel: LectureModel(json: lecture))
                    lectures.append(row);
                }
            }
        }
        
        // 今天有人文讲座
        if lectures.count > 0 {
            let model = CardsModel(cellId: "CardsCellLecture", module: ModuleLecture, desc: "今天有新的人文讲座，有兴趣的同学欢迎参加", priority: .CONTENT_NOTIFY)
            model.rows.append(contentsOf: lectures)
            return model;
        }
        
        // 今天无人文讲座
        var desc = jsonArray.count == 0 ? "暂无人文讲座预告信息" : "暂无新的人文讲座，点我查看以后的预告"
        if !ApiHelper.isLogin() {
            desc = "暂无最近讲座预告，登录可查询讲座记录"
        }
        
        return CardsModel(cellId: "CardsCellLecture", module: ModuleLecture, desc: desc, priority: .NO_CONTENT)
    }
}
