//
//  NSDate.swift
//  curriculum
//
//  Created by 于海通 on 16/2/27.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import Foundation;

extension NSDate {
    func dayOfWeek() -> Int {
        let interval = self.timeIntervalSince1970;
        let days = Int(interval / 86400);
        return (days - 3) % 7;
    }
}