//
//  ApiCache.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class ApiCache {
    
    enum CacheTimeout {
        case Instant
        case Daily
        case Weekly
        case Monthly
        case Yearly
        case Forever
    }
    
    var cacheName : String
    
    var request = ApiRequest()
    
    var timeout : CacheTimeout
    
    var clearOnLogout : Bool
    
    var errorPool : 
    
    init (cacheName : String, api : String, params : [String], withUuid : Bool, parser : ApiRequest.JSONParser, timeout : CacheTimeout, clearOnLogout : Bool) {
        self.cacheName = cacheName
        self.request = request.api(api).
    }
}