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
        "herald_grade_gpa",
        "herald_lecture_records",
        "herald_experiment",
        "herald_nic",
        "herald_srtp",
        "herald_curriculum",
        "herald_pedetail",
        "herald_sidebar",
        "herald_exam",
        "herald_schedule_cache_time",
        "herald_library_borrowbook"
    ]
    
    static let cache = NSUserDefaults.withPrefix("herald_")
    
    static func get(cacheName : String) -> String {
        return cache.get(cacheName)
    }
    
    static func set(cacheName : String, cacheValue : String) {
        cache.set(cacheName, cacheValue)
    }
    
    static func clearAllModuleCache () {
        for k in cacheNames {
            set(k, cacheValue: "")
        }
    }
}