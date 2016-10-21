//
//  CardCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class CardCard {
    
    static func getRefresher () -> ApiRequest {
        return Cache.cardToday.refresher
    }
    
    static func getCard() -> CardsModel {
        if !ApiHelper.isLogin() {
            return CardsModel(cellId: "CardsCellCard", module: ModuleCard, desc: "登录可使用消费查询、充值、余额提醒功能", priority: .NO_CONTENT)
        }
        
        let cache = Cache.cardToday.value
        let content = JSON.parse(cache)["content"]
        // 获取余额并且设置
        if let extra = Float(content["left"].stringValue.replaceAll(",", "")) {
            if extra < 20 {
                return CardsModel(cellId: "CardsCellCard", module: ModuleCard, desc: "一卡通余额还有\(String(format: "%.2f", extra))元，快去充值~\n如果已经充值过了，需要在食堂刷卡一次才会更新哦~", priority: .CONTENT_NOTIFY)
            } else {
                return CardsModel(cellId: "CardsCellCard", module: ModuleCard, desc: "你的一卡通余额还有\(String(format: "%.2f", extra))元", priority: .CONTENT_NO_NOTIFY)
            }
        } else {
            return CardsModel(cellId: "CardsCellCard", module: ModuleCard, desc: "一卡通数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
    }
}