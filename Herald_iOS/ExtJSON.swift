import Foundation
import SwiftyJSON

extension JSON {
    
    /// 新增一个不带 Optional 的属性，代替 rawString，方便使用
    var rawStringValue : String {
        if type == .Number {
            return String(intValue)
        } else if type == .String {
            return stringValue
        } else if let string = rawString() {
            return string
        } else {
            return ""
        }
    }
}