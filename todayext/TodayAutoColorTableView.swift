//
//  TodayAutoColorTableView.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/26.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit

class TodayAutoColorTableView: UITableView {
    
    override func didMoveToSuperview() {
        if #available(iOSApplicationExtension 10.0, *) {
            separatorColor = .lightGray
        } else {
            separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        }
    }
}
