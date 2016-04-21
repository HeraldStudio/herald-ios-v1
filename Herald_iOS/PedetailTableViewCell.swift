//
//  CardItemView.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar

class PedetailTableViewCell : UITableViewCell {
    
    var year: Int?, month: Int?

    var dates: [Int] = []
    
    var calendar = FSCalendar()
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        for k in subviews { k.removeFromSuperview() }
        calendar.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(calendar)
    }
}