import Foundation
import SwiftyJSON

class GymSportModel {
    var id : Int
    var name : String
    var allowHalf : Bool
    var fullMinUsers : Int
    var fullMaxUsers : Int
    var halfMinUsers : Int
    var halfMaxUsers : Int
    
    init (json : JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        allowHalf = json["allowHalf"].intValue != 0
        fullMinUsers = json["fullMinUsers"].intValue
        fullMaxUsers = json["fullMaxUsers"].intValue
        halfMinUsers = json["halfMinUsers"].intValue
        halfMaxUsers = json["halfMaxUsers"].intValue
    }
}