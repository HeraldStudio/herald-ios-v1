import Foundation
import SwiftyJSON

extension JSON {
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