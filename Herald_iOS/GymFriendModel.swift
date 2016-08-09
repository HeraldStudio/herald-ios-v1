import Foundation
import SwiftyJSON

class GymFriendModel {
    var nameDepartment : String
    var userId : Int
    var userInfo : String
    
    init (json : JSON) {
        nameDepartment = json["nameDepartment"].stringValue
        userId = json["userId"].intValue
        userInfo = json["userInfo"].stringValue
    }
    
    static var friendCache : [JSON] {
        get {
            var cache = Cache.gymReserveFriend.value
            if cache == "" {
                cache = "[]"
            }
            return JSON.parse(cache).arrayValue
        } set (value) {
            let str = JSON(value).rawString()
            Cache.gymReserveFriend.value = str ?? ""
        }
    }
    
    var json : JSON {
        return JSON(["nameDepartment": nameDepartment, "userId": userId, "userInfo": userInfo])
    }
    
    var isMyFriend : Bool {
        for friend in GymFriendModel.friendCache {
            if GymFriendModel(json : friend) == self {
                return true
            }
        }
        return false
    }
    
    func addFriend () {
        if !isMyFriend {
            GymFriendModel.friendCache = GymFriendModel.friendCache + [json]
        }
    }
    
    func removeFriend () {
        if isMyFriend {
            var oldCache = GymFriendModel.friendCache
            var index = 0
            for i in 0 ..< GymFriendModel.friendCache.count {
                if GymFriendModel(json: GymFriendModel.friendCache[i]) == self {
                    index = i
                    break
                }
            }
            
            oldCache.removeAtIndex(index)
            GymFriendModel.friendCache = oldCache
        }
    }
    
    func toggleFriend () {
        if isMyFriend {
            removeFriend()
        } else {
            addFriend()
        }
    }
    
    var name : String {
        return nameDepartment.split("(")[0]
    }
    
    var department : String {
        if nameDepartment.split("(").count < 2 {
            return ""
        }
        return nameDepartment.split("(")[1].split(")")[0]
    }
}

func == (left : GymFriendModel, right : GymFriendModel) -> Bool {
    return left.userId == right.userId
}