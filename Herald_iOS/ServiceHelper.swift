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
    
    static func get(key : String) -> String {
        return serviceCache.get(key)
    }
    
    static func set(key : String, _ value : String) {
        serviceCache.set(key, value)
    }
}