//
//  LectureHistoryModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/// 此类兼做讲座预告的模型和讲座记录的模型。
class LectureModel {
    var topic : String
    var speaker : String
    var dateAndPlace : String
    
    init (_ topic : String, _ speaker : String, _ dateAndPlace : String) {
        self.topic = topic
        self.speaker = speaker
        self.dateAndPlace = dateAndPlace
    }
    
    convenience init (json : JSON) {
        let topic = json["topic"].stringValue
        let speaker = json["speaker"].stringValue
        let date = json["date"].stringValue
        let location = json["location"].stringValue
        
        let dateAndPlace = date + " @" + location
        self.init(topic, speaker, dateAndPlace)
    }
}