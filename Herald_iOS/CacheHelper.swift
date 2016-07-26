//
//  CacheHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class CacheHelper {
    
    // 缓存名称列表，注销时将取消这些缓存
    static let cacheNames = [
        "authUser",
        "authPwd",
        "herald_card",
        "herald_card_left",
        "herald_card_date",
        "herald_card_today",
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
    
    static let cache = NSUserDefaults.withPrefix("herald_")
    
    static func get(cacheName : String) -> String {
        return cache.get(cacheName)
    }
    
    static var reflectionMap : [String : String] = [:]
    
    /// 返回值为该缓存与之前相比是否有变化
    static func set(cacheName : String, _ cacheValue : String) -> Bool {
        let oldValue = cache.get(cacheName)
        cache.set(cacheName, cacheValue)
        
        /// TODO
        reflectionMap.updateValue(cacheValue, forKey: "herald_" + cacheName)
        
        // 此处首先判断旧值是否为空，若旧值为空说明是初次更新
        // 因为初次更新无法判断实际数据是否发生了变化，同时也是为了为了首次启动时不干扰用户，所以初次更新时不显示小红点
        return oldValue != "" && cacheValue != oldValue
    }
    
    static func clearAllModuleCache () {
        for k in cacheNames {
            set(k, "")
        }
    }
}