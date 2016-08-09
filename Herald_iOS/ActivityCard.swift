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
    
    static func getRefresher () -> ApiRequest {
        return Cache.activityHot.refresher
    }
    
    static func getCard () -> CardsModel {
        if Cache.activityHot.isEmpty {
            return CardsModel(cellId: "CardsCellActivity", icon : "ic_activity-1", title : "校园活动", desc: "热门活动数据为空，请尝试刷新", dest : "TAB1", message: "", priority: .CONTENT_NOTIFY)
        }
        let cache = Cache.activityHot.value
        
        let content = JSON.parse(cache)["content"]
        
        var allActivities : [CardsRowModel] = []
        
        for activity in content.arrayValue {
            // 根据json创建对应的活动模型
            let activityModel = ActivityModel(activity)
            allActivities.append(CardsRowModel(activityModel: activityModel))
        }
        
        if allActivities.count == 0 {
            // 无活动信息
            return CardsModel(cellId: "CardsCellActivity", icon : "ic_activity-1", title : "校园活动", desc : "最近没有新的热门校园活动", dest : "TAB1", message: "", priority : .NO_CONTENT)
        } else {
            let model = CardsModel(cellId: "CardsCellActivity", icon : "ic_activity-1", title : "校园活动", desc : "最近有新的热门校园活动，欢迎来参加~", dest : "TAB1", message: "", priority : .CONTENT_NOTIFY)
            model.rows.appendContentsOf(allActivities)
            return model
        }
    }
}