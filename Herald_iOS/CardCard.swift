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
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().api("card").uuid().post("timedelta", "1").toCache("herald_card_today")]
    }
    
    static func getCard() -> CardsModel {
        let cache = CacheHelper.get("herald_card_today")
        let content = JSON.parse(cache)["content"]
        // 获取余额并且设置
        if let extra = Float(content["cardLeft"].stringValue.replaceAll(",", "")) {
            if extra < 20 {
                let model = CardsModel(cellId: "CardsCellCard", module: R.module.card, desc: "一卡通余额还有\(String(format: "%.2f", extra))元，快点我充值~\n如果已经充值过了，需要刷卡消费一次才会更新哦~", priority: .CONTENT_NOTIFY)
                model.rows[0].destination = CardViewController.url
                return model
            } else {
                return CardsModel(cellId: "CardsCellCard", module: R.module.card, desc: "你的一卡通余额还有\(String(format: "%.2f", extra))元", priority: .CONTENT_NO_NOTIFY)
            }
        } else {
            return CardsModel(cellId: "CardsCellCard", module: R.module.card, desc: "一卡通数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
    }
}