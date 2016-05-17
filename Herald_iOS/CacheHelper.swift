//
//  CacheHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class CacheHelper : NSObject {
    
    // 缓存名称列表，注销时将取消这些缓存
    static let cacheNames = [
        "authUser",
        "authPwd",
        "herald_card",
        "herald_card_left",
        "herald_card_date",
        "herald_card_charged",
        "herald_grade_gpa",
        "herald_lecture_records",
        "herald_experiment",
        "herald_nic",
        "herald_srtp",
        "herald_curriculum",
        "herald_pedetail",
        "herald_pe_count",
        "herald_pe_remain",
        "herald_sidebar",
        "herald_exam",
        "herald_schedule_cache_time",
        "herald_library_borrowbook",
        "herald_gymreserve_userid",
        "herald_gymreserve_phone"
    ]
    
    /// 调试用，覆盖某些特定的cache内容
    static let overrides : [String : String] = [:]
    
    static let cache = NSUserDefaults.withPrefix("herald_")
    
    static func get(cacheName : String) -> String {
        if overrides.keys.contains(cacheName) {
            return overrides[cacheName]!
        }
        return cache.get(cacheName)
    }
    
    static func set(cacheName : String, _ cacheValue : String) {
        cache.set(cacheName, cacheValue)
    }
    
    static func clearAllModuleCache () {
        for k in cacheNames {
            set(k, "")
        }
    }
}