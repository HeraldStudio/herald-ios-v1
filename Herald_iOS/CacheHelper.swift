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
        "herald_grade_gpa",
        "herald_lecture_records",
        "herald_experiment",
        "herald_nic",
        "herald_srtp",
        "herald_curriculum",
        "herald_pedetail",
        "herald_sidebar",
        "herald_exam",
        "herald_schedule_cache_time"
    ]
    
    static let cache = NSUserDefaults.withPrefix("herald_")
    static let serviceCache = NSUserDefaults.withPrefix("service_")
    
    static func getCache (cacheName : String) -> String {
        return cache.get(cacheName)
    }
    
    static func setCache (cacheName : String, cacheValue : String) {
        cache.put(cacheName, withValue: cacheValue)
    }
    
    static func getServiceCache (cacheName : String) -> String {
        return serviceCache.get(cacheName)
    }
    
    static func setServiceCache (cacheName : String, cacheValue : String) {
        serviceCache.put(cacheName, withValue: cacheValue)
    }
    
    static func clearAllModuleCache () {
        for k in cacheNames {
            setCache(k, cacheValue: "")
        }
    }
}