import Foundation
import SwiftyJSON

class GameCardModel {
    var name : String
    var desc : String
    var pic : String
    var count : Int
    
    init (json : JSON) {
        name = json["name"].stringValue
        desc = json["desc"].stringValue
        pic = json["pic"].stringValue
        count = 1
    }
    
    init (name : String) {
        self.name = name
        desc = ""
        pic = ""
        count = 1
    }
    
    func eachCardToJSON () -> JSON {
        return JSON(["name": name, "desc": desc, "pic": pic])
    }
}

func == (left: GameCardModel, right: GameCardModel) -> Bool {
    return left.name == right.name && left.desc == right.desc && left.pic == right.pic
}