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
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().url(ApiHelper.wechat_lecture_notice_url).uuid()
            .toCache("herald_lecture_notices") {json -> String in
                guard let str = json.rawString() else {return ""}
                return str
            }]
    }
    
    static func getCard() -> CardsModel {
        
        let cache = CacheHelper.get("herald_lecture_notices")
        
        let jsonArray = JSON.parse(cache)["content"]
        var lectures : [CardsRowModel] = []
        
        for lecture in jsonArray.arrayValue {
            let dateStr = lecture["date"].stringValue.split("日")[0]
            let date = dateStr.replaceAll("年", "-").replaceAll("月", "-").split("-")
            let mdStr = [date[date.count - 2], date[date.count - 1]]
            guard let month = Int(mdStr[0]) else { continue }
            guard let day = Int(mdStr[1]) else { continue }
            
            let time = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
            if (time.month == month && time.day == day) {
                if (time.hour * 60 + time.minute < 19 * 60) {
                    let row = CardsRowModel(lectureModel: LectureModel(json: lecture))
                    lectures.append(row);
                }
            }
        }
        
        // 今天有人文讲座
        if lectures.count > 0 {
            let model = CardsModel(cellId: "CardsCellLecture", module: .Lecture, desc: "今天有新的人文讲座，有兴趣的同学欢迎参加", priority: .CONTENT_NO_NOTIFY)
            model.rows.appendContentsOf(lectures)
            return model;
        }
        
        // 今天无人文讲座
        return CardsModel(cellId: "CardsCellLecture", module: .Lecture, desc: jsonArray.count == 0 ? "暂无人文讲座预告信息" : "暂无新的人文讲座，点我查看以后的预告", priority: .NO_CONTENT)
    }
}