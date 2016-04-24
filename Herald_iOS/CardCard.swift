//
//  CardCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/*class CardCard {
    
    static let 余额不足临界值 : Float = 20
    
    static func getCard() -> CardsModel {
        let cache = CacheHelper.get("herald_card")
        let content = JSON.parse(cache)["content"]
        // 获取余额并且设置
        let _extra = Float(content["left"].stringValue)
        let extra = _extra != nil ? _extra! : 0
        
        // 若检测到超过上次忽略时的余额，认为已经充值过了，取消忽略充值提醒
        var isNumber = true
        if let ignored = Float(CacheHelper.get("herald_card_charged")) {
            if extra > ignored {
                CacheHelper.set("herald_card_charged", cacheValue: "")
                isNumber = false
            }
        } else {isNumber = false}
        
        if extra < 余额不足临界值 {
            // 若没有被忽略的充值提醒，或者超过上次忽略提醒时的余额，认为余额不足需要提醒
            
        }
    }
}*/