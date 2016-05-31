//
//  ExamCard.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * 读取考试缓存，转换成对应的时间轴条目
 **/
class ExamCard {
    
    static func getRefresher () -> [ApiRequest] {
        return [ApiRequest().api("exam").uuid().toCache("herald_exam")]
    }

    static func getCard() -> CardsModel {
        let cache = CacheHelper.get("herald_exam")
        let customCache = CacheHelper.get("herald_exam_custom_\(ApiHelper.getUserName())")
        let json = JSON.parse(cache)["content"]
        let jsonCustom = JSON.parse(customCache)
        
        var examList : [CardsRowModel] = []
        
        for exam in json.arrayValue {
            do {
                let examItem = try ExamModel(json: exam)
                if (examItem.days >= 0) {
                    examList.append(CardsRowModel(examModel: examItem))
                }
            } catch { continue }
        }
        
        for exam in jsonCustom.arrayValue {
            do {
                let examItem = try ExamModel(json: exam)
                if (examItem.days >= 0) {
                    examList.append(CardsRowModel(examModel: examItem))
                }
            } catch { continue }
        }
        
        examList = examList.sort({$0.sortOrder < $1.sortOrder})
        
        if (examList.count == 0) {
            return CardsModel(cellId: "CardsCellExam", module: R.module.exam, desc: "最近没有新的考试安排", priority: .NO_CONTENT)
        } else {
            let model = CardsModel(cellId: "CardsCellExam", module: R.module.exam, desc: "你最近有\(examList.count)场考试，抓紧时间复习吧", priority: .CONTENT_NO_NOTIFY)
            model.rows.appendContentsOf(examList)
            return model;
        }
    }
}