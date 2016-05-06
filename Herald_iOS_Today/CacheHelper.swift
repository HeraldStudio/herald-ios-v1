//
//  CacheHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class CacheHelper : NSObject {
    
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
}