//
//  NSUserDefaults.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    static func withPrefix (prefix : String) -> PrefixUserDefaults {
        return PrefixUserDefaults(defaults: standardUserDefaults(), prefix: prefix)
    }
}

class PrefixUserDefaults {
    
    var defaults : NSUserDefaults
    
    var prefix : String
    
    init (defaults : NSUserDefaults, prefix : String) {
        self.defaults = defaults
        self.prefix = prefix
    }
    
    func get (key : String) -> String {
        if let k = defaults.stringForKey(prefix + key) {
            return k
        }
        return ""
    }
    
    func put (key : String, withValue value : String) {
        defaults.setObject(value, forKey: prefix + key)
        defaults.synchronize()
    }
}