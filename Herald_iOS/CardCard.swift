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
    
    static func getCard() -> CardsModel {
        let cache = CacheHelper.get("herald_card")
        let content = JSON.parse(cache)["content"]
        // 获取余额并且设置
        if let extra = Float(content["left"].stringValue) {
            if extra < 20 {
                let model = CardsModel(cellId: "CardsCellCard", module: .Card, desc: "一卡通余额还有\(String(format: "%.2f", extra))元，快点我充值~\n如果已经充值过了，需要刷卡消费一次才会更新哦~", priority: .CONTENT_NOTIFY)
                model.rows[0].destination = CardViewController.url
                return model
            } else {
                return CardsModel(cellId: "CardsCellCard", module: .Card, desc: "你的一卡通余额还有\(String(format: "%.2f", extra))元", priority: .CONTENT_NO_NOTIFY)
            }
        } else {
            return CardsModel(cellId: "CardsCellCard", module: .Card, desc: "一卡通余额数据加载失败，请手动刷新", priority: .NO_CONTENT)
        }
    }
}