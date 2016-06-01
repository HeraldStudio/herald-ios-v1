//
//  JwcCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/25.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class JwcCard {
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().api("jwc").uuid().toCache("herald_jwc")]
    }
    
    static func getCard () -> CardsModel {
        let cache = CacheHelper.get("herald_jwc")
        if cache == "" {
            return CardsModel(cellId: "CardsCellJwc", module: R.module.jwc, desc: "教务通知数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let content = JSON.parse(cache)["content"]["教务信息"]
        
        var allNotices : [CardsRowModel] = []
        
        for notice in content.arrayValue {
            // 根据json创建对应的通知模型，这里如果是今天或昨天的通知，则时间已经被改成"今天"或"昨天"
            let noticeModel = JwcNoticeModel(json: notice)
            // 只要判断时间里有没有"天"字就可以知道是不是这两天的通知
            if noticeModel.time.containsString("天") {
                allNotices.append(CardsRowModel(jwcNoticeModel: noticeModel))
            }
        }
        
        if allNotices.count == 0 {
            // 无教务信息
            return CardsModel(cellId: "CardsCellJwc", module: R.module.jwc, desc: "最近没有新的核心教务通知", priority: .NO_CONTENT)
        } else {
            let model = CardsModel(cellId: "CardsCellJwc", module: R.module.jwc, desc: "最近有新的核心教务通知，有关同学请关注", priority: .CONTENT_NOTIFY)
            model.rows.appendContentsOf(allNotices)
            return model
        }
    }
}