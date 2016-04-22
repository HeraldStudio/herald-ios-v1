//
//  JwcNoticeModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class JwcNoticeModel {
    var title : String
    var time : String
    var url : String
    
    init (_ title : String, _ time : String, _ url : String) {
        self.title = title
        self.time = time
        self.url = url
    }
}