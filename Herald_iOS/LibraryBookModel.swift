//
//  LibraryBookModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

class LibraryBookModel {
    var title : String
    var line1 : String
    var line2 : String
    var barcode : String
    var count : String
    
    init (borrowedBookJson json : JSON) {
        title = json["title"].stringValue
        line1 = json["author"].stringValue
        let dueDate = json["due_date"].stringValue
        let renderDate = json["render_date"].stringValue
        let renewTime = json["renew_time"].stringValue
        line2 = "\(renderDate)借书 / \(dueDate)到期"
        
        barcode = json["barcode"].stringValue
        count = renewTime == "0" ? "点击续借" : "已续借"
    }
    
    init (hotBookJson json : JSON) {
        self.title = json["name"].stringValue
        self.line1 = json["author"].stringValue
        self.line2 = json["place"].stringValue
        self.barcode = ""
        self.count = "借阅" + json["count"].stringValue + "次"
    }
    
    init (searchResultJson json : JSON) {
        self.title = json["name"].stringValue
        self.line1 = json["author"].stringValue + "，" + json["publish"].stringValue
        self.line2 = json["index"].stringValue
        self.barcode = ""
        self.count = "剩余" + json["left"].stringValue + "本"
    }
}