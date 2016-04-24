//
//  ServiceHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServiceHelper {
    
    static let serviceCache = NSUserDefaults.withPrefix("service_")
    
    static func refreshCache (doAfter : (() -> Void)?) {
        ApiRequest().url("http://android.heraldstudio.com/checkversion").uuid()
            .post("schoolnum", "0", "versioncode", "0")
            .toServiceCache("versioncheck_cache") { (json) -> String in json.rawString()!}
            .onFinish { (_, _, _) -> Void in
                doAfter?()
            }
            .run()
    }
    
    static func get(key : String) -> String {
        return serviceCache.get(key)
    }
    
    static func set(key : String, _ value : String) {
        serviceCache.set(key, value)
    }
    
    static func getPushMessageContent() -> String {
        // 获得服务器端推送消息
        let cache = get("versioncheck_cache")
        return JSON.parse(cache)["content"]["message"]["content"].stringValue
    }
    
    static func getPushMessageUrl() -> String {
        // 获得服务器端推送消息
        let cache = get("versioncheck_cache")
        return JSON.parse(cache)["content"]["message"]["url"].stringValue
    }
    
    static func getPushMessageItem() -> CardsModel? {
        let pushMessage = getPushMessageContent()
        if pushMessage != "" {
            let fakeModule = AppModule(id: -1, name: "", nameTip: "小猴提示", desc: "", controller: "", icon: "ic_pushmsg", hasCard: false)
            let card = CardsModel(fakeModule, "现在", pushMessage, Priority.CONTENT_NOTIFY)
            return card
        }
        return nil
    }
}