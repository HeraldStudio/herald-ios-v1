import Foundation
import SwiftyJSON

class GymTimeModel {
    var usedSite : Int
    var enable : Bool
    var surplus : Int
    var siteIdHalf : String
    var availableTime : String
    var startTime : [String : Int]
    var endTime : [String : Int]
    var siteIdAll : String
    var allSite : Int
    
    init (json : JSON) {
        usedSite = json["usedSite"].intValue
        enable = json["enable"].boolValue
        surplus = json["surplus"].intValue
        siteIdHalf = json["siteIdHalf"].stringValue
        availableTime = json["avaliableTime"].stringValue
        startTime = [:]
        for (str, json) in json["startTime"].dictionaryValue {
            startTime.updateValue(json.intValue, forKey: str)
        }
        endTime = [:]
        for (str, json) in json["endTime"].dictionaryValue {
            endTime.updateValue(json.intValue, forKey: str)
        }
        siteIdAll = json["siteIdAll"].stringValue
        allSite = json["allSite"].intValue
    }
}