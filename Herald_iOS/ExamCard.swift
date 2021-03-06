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
    
    static func getRefresher () -> ApiRequest {
        return Cache.exam.refresher
    }

    static func getCard() -> CardsModel {
        if !ApiHelper.isLogin() {
            return CardsModel(cellId: "CardsCellExam", module: ModuleExam, desc: "登录即可使用考试查询、智能提醒功能", priority: .NO_CONTENT)
        }
        
        if Cache.exam.isEmpty {
            return CardsModel(cellId: "CardsCellExam", module: ModuleExam, desc: "考试数据为空，请尝试刷新", priority: .CONTENT_NOTIFY)
        }
        
        let cache = Cache.exam.value
        
        let customCache = Cache.examCustom.value
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
        
        examList = examList.sorted(by: {$0.sortOrder < $1.sortOrder})
        
        if (examList.count == 0) {
            return CardsModel(cellId: "CardsCellExam", module: ModuleExam, desc: "最近没有新的考试安排", priority: .NO_CONTENT)
        } else {
            let model = CardsModel(cellId: "CardsCellExam", module: ModuleExam, desc: "你最近有\(examList.count)场考试，抓紧时间复习吧", priority: .CONTENT_NO_NOTIFY)
            model.rows.append(contentsOf: examList)
            return model;
        }
    }
}
