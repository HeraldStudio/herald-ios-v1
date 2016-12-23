import Foundation
import SwiftyJSON

extension JSON {
    
    /// 新增一个不带 Optional 的属性，代替 rawString，方便使用
    var rawStringValue : String {
        if type == .number {
            return String(intValue)
        } else if type == .string {
            return stringValue
        } else if let string = rawString() {
            return string
        } else {
            return ""
        }
    }
}
