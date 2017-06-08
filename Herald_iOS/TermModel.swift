//
//  TermModel.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/24.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation

class TermModel {
    var beginYear : Int
    var endYear : Int
    var period : Int
    
    init(_ raw: String) {
        var parts = raw.components(separatedBy: "-")
        parts.append("0")
        parts.append("0")
        beginYear = Int(parts[0]) ?? 0
        endYear = Int(parts[1]) ?? 0
        period = Int(parts[2]) ?? 1
    }
    
    var beginDesc : String {
        return "20\(beginYear)"
    }
    
    var endDesc : String {
        return "20\(endYear)"
    }
    
    var yearDesc : String {
        return beginDesc + "~" + endDesc + "年度"
    }
    
    var periodDesc : String {
        return ["短学期", "秋季学期", "春季学期"][period - 1]
    }
    
    var desc : String {
        return yearDesc + periodDesc
    }
    
    var rawString : String {
        return "\(beginYear)-\(endYear)-\(period)"
    }
    
    var nextTerm : TermModel {
        let ret = TermModel(rawString)
        ret.period += 1
        if ret.period > 3 {
            ret.period = 1
            ret.beginYear += 1
            ret.endYear += 1
        }
        return ret
    }
    
    var isAfterUserRegister : Bool {
        let cardnum = ApiHelper.currentUser.userName
        if let registerYear = Int(cardnum.substring(3..<5)) {
            return registerYear <= beginYear
        }
        return false
    }
}
