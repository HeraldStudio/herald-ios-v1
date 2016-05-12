//
//  ActivityCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/11.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActivityCard {
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().get().url("http://115.28.27.150/herald/api/v1/huodong/get?type=hot").toCache("herald_activity_hot") {
            json -> String in
            guard let str = json.rawString() else {return ""}
            return str
            }]
    }
    
    static func getCard () -> CardsModel {
        let cache = CacheHelper.get("herald_activity_hot")
        let content = JSON.parse(cache)["content"]
        
        var allActivities : [CardsRowModel] = []
        
        for activity in content.arrayValue {
            // 根据json创建对应的活动模型
            let activityModel = ActivityModel(activity)
            allActivities.append(CardsRowModel(activityModel: activityModel))
        }
        
        if allActivities.count == 0 {
            // 无活动信息
            return CardsModel(cellId: "CardsCellActivity", icon : "ic_activity-1", title : "校园活动", desc : "最近没有新的校园活动", dest : "", priority : .NO_CONTENT)
        } else {
            let model = CardsModel(cellId: "CardsCellActivity", icon : "ic_activity-1", title : "校园活动", desc : "最近有新的热门校园活动，欢迎来参加~", dest : "", priority : .CONTENT_NOTIFY)
            model.rows.appendContentsOf(allActivities)
            return model
        }
    }
}