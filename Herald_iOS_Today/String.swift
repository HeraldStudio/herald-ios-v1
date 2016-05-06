//
//  String.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

extension String {
    
    func split (separator : String) -> [String] {
        return componentsSeparatedByString(separator)
    }
    
    func replaceAll (src : String, _ dst : String) -> String {
        return stringByReplacingOccurrencesOfString(src, withString: dst)
    }
}